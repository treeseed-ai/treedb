defmodule TreeDb.Audit do
  @moduledoc false

  def append(event_type, attrs \\ %{}) do
    input =
      %{
        eventType: event_type,
        actorId: Map.get(attrs, :actor_id),
        tenantId: Map.get(attrs, :tenant_id),
        repoId: Map.get(attrs, :repo_id),
        nodeId: Map.get(attrs, :node_id) || System.get_env("TREEDB_NODE_ID") || "node_local",
        requestId: Map.get(attrs, :request_id),
        data: Map.get(attrs, :data, %{})
      }

    TreeDb.Store.append_audit_event(input)
  end
end
