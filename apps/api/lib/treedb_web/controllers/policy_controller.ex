defmodule TreeDbWeb.PolicyController do
  use Phoenix.Controller, formats: [:json]
  import TreeDbWeb.ControllerHelpers

  def effective_scope(conn, params) do
    principal = conn.assigns[:principal]
    repo_id = params["repoId"] || params["repo_id"]

    case TreeDb.Capabilities.effective_scope(principal, repo_id) do
      {:ok, scope} ->
        TreeDb.Audit.append("policy.effective_scope_resolved", %{
          actor_id: scope["actorId"],
          tenant_id: scope["tenantId"],
          repo_id: repo_id
        })

        ok(conn, %{effectiveScope: scope})

      {:error, error} ->
        error(conn, status_for(error[:code] || error["code"]), error)
    end
  end

  def refresh(conn, _params) do
    TreeDb.Audit.append("policy.refresh_requested")

    if TreeDb.Auth.mode() == "dev" do
      ok(conn, %{refreshed: false, mode: "dev"})
    else
      error(conn, 501, %{
        code: "not_implemented",
        message: "Connected policy refresh is not implemented."
      })
    end
  end
end
