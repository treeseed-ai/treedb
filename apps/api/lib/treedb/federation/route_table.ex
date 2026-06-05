defmodule TreeDb.Federation.RouteTable do
  @moduledoc false

  def resolve(repo_id) do
    local_node = TreeDb.Federation.NodeIdentity.node_id()

    with {:ok, placement} when is_map(placement) <- TreeDb.Store.get_repository_placement(repo_id) do
      source = if placement["primaryNodeId"] == local_node, do: "local", else: "remote"

      {:ok,
       %{
         "repositoryId" => repo_id,
         "primaryNodeId" => placement["primaryNodeId"],
         "mirrorNodeIds" => placement["mirrorNodeIds"] || [],
         "readPolicy" => placement["readPolicy"] || "primary_or_mirror",
         "writePolicy" => placement["writePolicy"] || "primary_only",
         "source" => source,
         "baseUrl" => base_url(placement["primaryNodeId"])
       }}
    else
      _ ->
        case TreeDb.Store.get_federation_route(repo_id) do
          {:ok, route} when is_map(route) ->
            {:ok, Map.put(route, "baseUrl", base_url(route["primaryNodeId"]))}

          _ ->
            {:error,
             %{
               code: "federated_route_not_configured",
               message: "Federated route is not configured."
             }}
        end
    end
  end

  def resolve_repo(repo_id_or_name, opts \\ []) do
    repo_id = resolve_repo_id(repo_id_or_name)

    case Keyword.get(opts, :mode, :read) do
      :write -> resolve_write(repo_id, opts)
      :read -> resolve_read(repo_id, opts)
      _ -> resolve(repo_id)
    end
  end

  def resolve_read(repo_id, opts \\ []) do
    with {:ok, route} <- resolve(repo_id) do
      local_node = TreeDb.Federation.NodeIdentity.node_id()

      cond do
        route["primaryNodeId"] == local_node ->
          {:ok, Map.merge(route, %{"source" => "local", "servedByNodeId" => local_node})}

        read_from_mirrors?() and local_node in (route["mirrorNodeIds"] || []) and
            mirror_fresh?(repo_id, local_node, opts) ->
          {:ok, Map.merge(route, %{"source" => "mirror", "servedByNodeId" => local_node})}

        trusted_query?(route["primaryNodeId"]) ->
          {:ok,
           Map.merge(route, %{"source" => "remote", "servedByNodeId" => route["primaryNodeId"]})}

        true ->
          {:error,
           %{
             code: "federated_route_not_configured",
             message: "Federated read route is not configured."
           }}
      end
    end
  end

  def resolve_write(repo_id, _opts \\ []) do
    with {:ok, route} <- resolve(repo_id) do
      local_node = TreeDb.Federation.NodeIdentity.node_id()

      cond do
        route["primaryNodeId"] == local_node ->
          {:ok, Map.merge(route, %{"source" => "local", "servedByNodeId" => local_node})}

        not write_proxy_enabled?() ->
          {:error, write_route_required(repo_id, route)}

        trusted_write_proxy?(route["primaryNodeId"]) ->
          {:ok,
           Map.merge(route, %{"source" => "remote", "servedByNodeId" => route["primaryNodeId"]})}

        true ->
          {:error,
           %{
             code: "federated_node_auth_forbidden",
             message: "Federated primary is not trusted for write proxy."
           }}
      end
    end
  end

  def resolve_workspace(workspace_id, opts \\ []) do
    local_node = TreeDb.Federation.NodeIdentity.node_id()

    with {:ok, route} when is_map(route) <- TreeDb.Store.get_workspace_route(workspace_id) do
      if route["nodeId"] == local_node do
        {:ok, Map.merge(route, %{"source" => "local", "servedByNodeId" => local_node})}
      else
        resolve_workspace_route(route, opts)
      end
    else
      _ ->
        case TreeDb.Store.get_workspace(workspace_id) do
          {:ok, workspace} ->
            {:ok,
             %{
               "workspaceId" => workspace_id,
               "repositoryId" => workspace["repoId"],
               "nodeId" => local_node,
               "source" => "local",
               "servedByNodeId" => local_node
             }}

          _ ->
            {:error, %{code: "not_found", message: "Workspace not found."}}
        end
    end
  end

  def local_primary?(repo_id) do
    with {:ok, route} <- resolve(repo_id) do
      route["primaryNodeId"] == TreeDb.Federation.NodeIdentity.node_id()
    else
      _ -> false
    end
  end

  def route_status(repo_id) do
    case resolve(repo_id) do
      {:ok, route} ->
        Map.take(route, ["repositoryId", "primaryNodeId", "mirrorNodeIds", "source"])

      {:error, error} ->
        %{"repositoryId" => repo_id, "status" => "unresolved", "error" => error[:code]}
    end
  end

  defp base_url(node_id) do
    cond do
      node_id == TreeDb.Federation.NodeIdentity.node_id() ->
        nil

      true ->
        case TreeDb.Store.get_federation_peer(node_id) do
          {:ok, peer} when is_map(peer) -> peer["baseUrl"]
          _ -> nil
        end
    end
  end

  defp resolve_repo_id(repo_id_or_name) do
    value = to_string(repo_id_or_name)

    cond do
      String.starts_with?(value, "repo_") ->
        value

      true ->
        normalized = TreeDb.RepositoryStorage.normalize_name(value)

        with {:ok, repos} <- TreeDb.Store.list_repositories(),
             repo when is_map(repo) <-
               Enum.find(
                 repos,
                 &((&1["repositoryName"] || &1["name"]) |> to_string() == normalized)
               ) do
          repo["id"]
        else
          _ ->
            case TreeDb.Store.list_federation_routes() do
              {:ok, routes} when is_list(routes) ->
                case Enum.find(routes, &(&1["repositoryName"] == normalized)) do
                  %{"repositoryId" => repo_id} -> repo_id
                  _ -> value
                end

              _ ->
                value
            end
        end
    end
  end

  defp resolve_workspace_route(route, _opts) do
    node_id = route["nodeId"]

    with true <- trusted_write_proxy?(node_id) or trusted_query?(node_id),
         {:ok, peer} when is_map(peer) <- TreeDb.Store.get_federation_peer(node_id),
         base_url when is_binary(base_url) and base_url != "" <- peer["baseUrl"] do
      {:ok,
       Map.merge(route, %{
         "source" => "remote",
         "servedByNodeId" => node_id,
         "baseUrl" => base_url
       })}
    else
      _ ->
        {:error,
         %{code: "federated_route_not_configured", message: "Workspace route is not configured."}}
    end
  end

  defp trusted_query?(node_id), do: TreeDb.Federation.Trust.trusted?(node_id, "trusted_for_query")

  defp trusted_write_proxy?(node_id),
    do: TreeDb.Federation.Trust.trusted?(node_id, "trusted_for_write_proxy")

  defp write_proxy_enabled?,
    do: System.get_env("TREEDB_FEDERATION_WRITE_PROXY_ENABLED", "true") not in ["false", "0"]

  defp read_from_mirrors?,
    do: System.get_env("TREEDB_FEDERATION_READ_FROM_MIRRORS", "true") not in ["false", "0"]

  defp mirror_fresh?(repo_id, node_id, _opts) do
    case TreeDb.Store.list_mirror_assignments(repo_id) do
      {:ok, assignments} when is_list(assignments) ->
        Enum.any?(assignments, fn assignment ->
          assignment["targetNodeId"] == node_id and assignment["status"] in ["healthy", "synced"] and
            fresh_enough?(assignment["lastSyncAt"])
        end)

      _ ->
        false
    end
  end

  defp fresh_enough?(nil), do: true

  defp fresh_enough?(timestamp) do
    max_age =
      System.get_env("TREEDB_FEDERATION_MAX_MIRROR_STALENESS_MS", "30000") |> String.to_integer()

    case DateTime.from_iso8601(timestamp) do
      {:ok, synced_at, _} -> DateTime.diff(DateTime.utc_now(), synced_at, :millisecond) <= max_age
      _ -> false
    end
  end

  defp write_route_required(repo_id, route) do
    %{
      code: "write_route_required",
      message: "Repository writes must be sent to the primary node.",
      details: %{repoId: repo_id, primaryNodeId: route["primaryNodeId"]}
    }
  end
end
