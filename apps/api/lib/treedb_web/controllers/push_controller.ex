defmodule TreeDbWeb.PushController do
  use Phoenix.Controller, formats: [:json]
  import TreeDbWeb.ControllerHelpers
  import TreeDbWeb.FederationProxyHelpers

  def push(conn, %{"repo_id" => repo_id} = params) do
    maybe_proxy_repo_write(conn, repo_id, params, fn conn ->
      with {:ok, principal} <- require_principal(conn) do
        handle_result(conn, TreeDb.Pushes.push(repo_id, params, principal))
      else
        {:error, error} -> error(conn, status_for(error[:code] || error["code"]), error)
      end
    end)
  end
end
