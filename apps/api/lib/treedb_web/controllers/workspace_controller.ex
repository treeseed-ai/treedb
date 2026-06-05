defmodule TreeDbWeb.WorkspaceController do
  use Phoenix.Controller, formats: [:json]
  import TreeDbWeb.ControllerHelpers
  import TreeDbWeb.FederationProxyHelpers

  def show(conn, %{"workspace_id" => workspace_id}) do
    maybe_proxy_workspace(conn, workspace_id, fn conn ->
      with {:ok, principal} <- require_principal(conn) do
        handle_result(conn, TreeDb.Workspaces.get(workspace_id, principal))
      else
        {:error, error} -> error(conn, status_for(error[:code] || error["code"]), error)
      end
    end)
  end

  def close(conn, %{"workspace_id" => workspace_id}) do
    maybe_proxy_workspace(conn, workspace_id, fn conn ->
      with {:ok, principal} <- require_principal(conn) do
        handle_result(conn, TreeDb.Workspaces.close(workspace_id, principal))
      else
        {:error, error} -> error(conn, status_for(error[:code] || error["code"]), error)
      end
    end)
  end
end
