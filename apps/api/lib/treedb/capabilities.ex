defmodule TreeDb.Capabilities do
  @moduledoc false

  def effective_scope(principal, repo_id \\ nil)

  def effective_scope(nil, repo_id) do
    if TreeDb.Auth.mode() == "dev" do
      effective_scope(%{"actorId" => "actor_demo"}, repo_id)
    else
      {:error, %{code: "authentication_required", message: "Authentication required."}}
    end
  end

  def effective_scope(principal, repo_id) do
    actor_id = principal["actorId"] || principal[:actorId] || principal[:actor_id]
    TreeDb.Store.resolve_effective_scope(actor_id, repo_id)
  end

  def require_capability(principal, capability, repo_id \\ nil)

  def require_capability(nil, _capability, _repo_id) do
    {:error, %{code: "authentication_required", message: "Authentication required."}}
  end

  def require_capability(principal, capability, repo_id) do
    with {:ok, scope} <- effective_scope(principal, repo_id) do
      if capability in (scope["capabilities"] || []) do
        {:ok, scope}
      else
        {:error,
         %{
           code: "permission_denied",
           message: "Permission denied.",
           details: %{capability: capability}
         }}
      end
    end
  end
end
