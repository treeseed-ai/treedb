defmodule TreeDbWeb.NodeController do
  use Phoenix.Controller, formats: [:json]
  import TreeDbWeb.ControllerHelpers

  def show(conn, _params) do
    with {:ok, principal} <- node_principal(conn),
         {:ok, _scope} <- TreeDb.Capabilities.require_capability(principal, "registry:read", nil),
         {:ok, node} <- TreeDb.Registry.node() do
      ok(conn, %{node: node})
    else
      {:error, error} -> error(conn, status_for(error[:code] || error["code"]), error)
    end
  end

  defp node_principal(conn) do
    case require_principal(conn) do
      {:ok, principal} ->
        {:ok, principal}

      {:error, _} ->
        if TreeDb.Auth.mode() == "dev" do
          {:ok, TreeDb.Auth.principal("actor_demo", "tenant_demo")}
        else
          {:error, %{code: "authentication_required", message: "Authentication required."}}
        end
    end
  end
end
