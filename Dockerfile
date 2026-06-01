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
RUN mix deps.get --only prod \
  && mix compile \
  && cargo build --release -p treedb_git --bin treedb_git_worker \
  && mix release \
  && cp ../../target/release/treedb_git_worker _build/prod/rel/treedb/bin/treedb_git_worker

FROM debian:bookworm-slim AS prod
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    TREEDB_DATA_DIR=/var/lib/treedb \
    PHX_SERVER=true
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates git openssl ripgrep tini \
  && useradd --system --create-home --home-dir /home/treedb treedb \
  && mkdir -p /var/lib/treedb \
  && chown -R treedb:treedb /var/lib/treedb \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build --chown=treedb:treedb /workspace/treedb/apps/api/_build/prod/rel/treedb ./
USER treedb
EXPOSE 4000
ENTRYPOINT ["tini", "--"]
CMD ["/app/bin/treedb", "start"]
