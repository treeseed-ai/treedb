import Config

config :treedb,
  namespace: TreeDb

config :treedb, TreeDb.Native,
  crate: :treedb_native,
  path: "native/treedb_native",
  mode: if(config_env() == :prod, do: :release, else: :debug)

config :treedb, TreeDbWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: TreeDbWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: nil,
  live_view: [signing_salt: "treedb"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{config_env()}.exs"
