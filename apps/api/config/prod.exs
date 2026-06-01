import Config

config :treedb, TreeDbWeb.Endpoint,
  server: true,
  secret_key_base: System.get_env("SECRET_KEY_BASE") || String.duplicate("c", 64)
