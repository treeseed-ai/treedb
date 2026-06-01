defmodule TreeDbWeb.HealthController do
  use Phoenix.Controller, formats: [:json]
  import TreeDbWeb.ControllerHelpers

  def health(conn, _params) do
    ok(conn, %{status: "ok", service: "treedb-api", dataDir: TreeDb.Store.data_dir()})
  end

  def version(conn, _params) do
    ok(conn, %{
      service: "treedb",
      version: TreeDb.Version.version(),
      apiVersion: TreeDb.Version.api_version()
    })
  end
end
