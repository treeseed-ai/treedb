# syntax=docker/dockerfile:1.7

FROM elixir:1.17.3-otp-27-slim AS base

ENV DEBIAN_FRONTEND=noninteractive \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:/usr/local/bin:$PATH

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    openssl \
    pkg-config \
    ripgrep \
    tini \
  && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain 1.95.0 \
  && mix local.hex --force \
  && mix local.rebar --force \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM base AS dev
WORKDIR /workspace/treedb/apps/api
ENV MIX_ENV=dev \
    TREEDB_DATA_DIR=/var/lib/treedb
EXPOSE 4000
ENTRYPOINT ["tini", "--"]
CMD ["mix", "phx.server"]

FROM base AS build
WORKDIR /workspace/treedb
ENV MIX_ENV=prod \
    TREEDB_DATA_DIR=/var/lib/treedb
COPY . .
WORKDIR /workspace/treedb/apps/api
RUN --mount=type=cache,target=/usr/local/cargo/registry \
  --mount=type=cache,target=/usr/local/cargo/git \
  --mount=type=cache,target=/workspace/treedb/target \
  --mount=type=cache,target=/workspace/treedb/apps/api/deps \
  mix deps.get --only prod \
  && mix compile \
  && cargo build --release -p treedb_git --bin treedb_git_worker \
  && mix release \
  && cc ../../docker-healthcheck.c -O2 -o _build/prod/rel/treedb/bin/treedb_healthcheck \
  && cp ../../target/release/treedb_git_worker _build/prod/rel/treedb/bin/treedb_git_worker \
  && release_vsn="$(cut -d' ' -f2 _build/prod/rel/treedb/releases/start_erl.data)" \
  && erts_vsn="$(cut -d' ' -f1 _build/prod/rel/treedb/releases/start_erl.data)" \
  && ln -s "$release_vsn" _build/prod/rel/treedb/releases/current \
  && ln -s "erts-$erts_vsn" _build/prod/rel/treedb/erts-current

FROM debian:bookworm-slim AS runtime-root
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates dpkg-dev libssl3 libstdc++6 libtinfo6 zlib1g \
  && arch="$(dpkg-architecture -qDEB_HOST_MULTIARCH)" \
  && mkdir -p "/runtime-root/usr/lib/${arch}" /runtime-root/etc/ssl/certs /runtime-root/var/lib/treedb \
  && cp -a /etc/ssl/certs/ca-certificates.crt /runtime-root/etc/ssl/certs/ \
  && for lib in \
    "/usr/lib/${arch}/libcrypto.so.3" \
    "/usr/lib/${arch}/libgcc_s.so.1" \
    "/usr/lib/${arch}/libssl.so.3" \
    "/usr/lib/${arch}/libstdc++.so.6" \
    "/usr/lib/${arch}/libtinfo.so.6" \
    "/usr/lib/${arch}/libz.so.1"; \
    do cp -L "$lib" "/runtime-root/usr/lib/${arch}/"; done \
  && chown -R 65532:65532 /runtime-root/var/lib/treedb \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM gcr.io/distroless/cc-debian12:nonroot AS prod
ENV LANG=C.UTF-8 \
    TREEDB_DATA_DIR=/var/lib/treedb \
    PHX_SERVER=true \
    BINDIR=/app/erts-current/bin \
    ROOTDIR=/app \
    EMU=beam \
    PROGNAME=erl \
    RELEASE_ROOT=/app \
    RELEASE_NAME=treedb \
    RELEASE_COMMAND=start \
    RELEASE_MODE=embedded \
    RELEASE_NODE=treedb \
    RELEASE_TMP=/app/tmp \
    RELEASE_DISTRIBUTION=none \
    RELEASE_SYS_CONFIG=/app/releases/current/sys
COPY --from=runtime-root /runtime-root/ /
WORKDIR /app
COPY --from=build --chown=65532:65532 /workspace/treedb/apps/api/_build/prod/rel/treedb ./
USER 65532:65532
EXPOSE 4000
CMD ["/app/erts-current/bin/erlexec", "+fnu", "-noshell", "-s", "elixir", "start_cli", "-mode", "embedded", "-setcookie", "treedb", "-config", "/app/releases/current/sys", "-boot", "/app/releases/current/start", "-boot_var", "RELEASE_LIB", "/app/lib", "-args_file", "/app/releases/current/vm.args", "-extra", "--no-halt"]
