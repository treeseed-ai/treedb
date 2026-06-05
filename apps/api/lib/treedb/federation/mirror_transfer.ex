defmodule TreeDb.Federation.MirrorTransfer do
  @moduledoc false

  def export(repo_id) do
    with {:ok, repo} when is_map(repo) <- TreeDb.Store.get_repository(repo_id),
         repo_path <- TreeDb.RepositoryStorage.path!(repo),
         {:ok, bundle_path} <- create_bundle(repo_path),
         {:ok, refs} <- TreeDb.Git.list_refs(repo_path),
         {:ok, bundle} <- File.read(bundle_path) do
      File.rm(bundle_path)

      {:ok,
       %{
         repoId: repo_id,
         repositoryName: repo["repositoryName"] || repo["name"],
         defaultRef: repo["defaultRef"] || "refs/heads/main",
         refs: refs["refs"] || refs,
         bundle: Base.encode64(bundle),
         bundleEncoding: "base64",
         sourceNodeId: TreeDb.Federation.NodeIdentity.node_id()
       }}
    else
      {:ok, nil} -> {:error, %{code: "not_found", message: "Repository not found."}}
      {:error, error} when is_map(error) -> {:error, error}
      {:error, reason} -> {:error, git_error(reason)}
      other -> {:error, git_error(other)}
    end
  end

  def import(repo_id, params, node_payload) do
    with repository_name when is_binary(repository_name) and repository_name != "" <-
           params["repositoryName"],
         bundle when is_binary(bundle) <- params["bundle"],
         {:ok, bytes} <- Base.decode64(bundle),
         {:ok, bundle_path} <- write_temp_bundle(bytes),
         {:ok, mirror_path} <- clone_mirror(repository_name, bundle_path),
         :ok <- File.rm(bundle_path),
         {:ok, assignment} <- put_assignment(repo_id, params, node_payload),
         {:ok, route} <- update_route(repo_id, repository_name, params, assignment) do
      {:ok,
       %{
         repoId: repo_id,
         repositoryName: repository_name,
         status: "synced",
         mirrorPath: Path.basename(mirror_path),
         assignment: assignment,
         route: sanitize_route(route)
       }}
    else
      nil -> {:error, %{code: "validation_error", message: "repositoryName is required."}}
      false -> {:error, %{code: "validation_error", message: "repositoryName is required."}}
      {:error, error} when is_map(error) -> {:error, error}
      {:error, reason} -> {:error, git_error(reason)}
      other -> {:error, git_error(other)}
    end
  end

  def sync_remote(repo_id, target_node_id) do
    with {:ok, peer} when is_map(peer) <- TreeDb.Store.get_federation_peer(target_node_id),
         base_url when is_binary(base_url) and base_url != "" <- peer["baseUrl"],
         {:ok, export} <- export(repo_id),
         {:ok, status, _headers, body} <-
           TreeDb.Federation.HttpClient.post_json(
             target_node_id,
             base_url,
             "/api/v1/internal/federation/repos/#{repo_id}/mirror/import",
             "mirror_import",
             export
           ),
         true <- status in 200..299,
         {:ok, %{"ok" => true} = mirror} <- Jason.decode(body) do
      {:ok, Map.drop(mirror, ["ok"])}
    else
      false ->
        {:error, %{code: "federated_mirror_unavailable", message: "Mirror import failed."}}

      {:ok, _status, _headers, body} ->
        {:error, %{code: "federated_mirror_unavailable", message: sanitize_body(body)}}

      {:error, error} when is_map(error) ->
        {:error, error}

      _ ->
        {:error, %{code: "federated_mirror_unavailable", message: "Mirror sync failed."}}
    end
  end

  defp create_bundle(repo_path) do
    bundle_path =
      Path.join(System.tmp_dir!(), "treedb-mirror-#{System.unique_integer([:positive])}.bundle")

    case System.cmd("git", ["bundle", "create", bundle_path, "--all"],
           cd: repo_path,
           stderr_to_stdout: true
         ) do
      {_output, 0} -> {:ok, bundle_path}
      {output, _} -> {:error, String.trim(output)}
    end
  end

  defp write_temp_bundle(bytes) do
    path =
      Path.join(System.tmp_dir!(), "treedb-import-#{System.unique_integer([:positive])}.bundle")

    File.write(path, bytes)
  end

  defp clone_mirror(repository_name, bundle_path) do
    with {:ok, normalized} <- TreeDb.RepositoryStorage.validate_name(repository_name) do
      mirror_path = TreeDb.RepositoryStorage.mirror_path(normalized)
      File.rm_rf!(mirror_path)
      File.mkdir_p!(Path.dirname(mirror_path))

      case System.cmd("git", ["clone", "--mirror", bundle_path, mirror_path],
             stderr_to_stdout: true
           ) do
        {_output, 0} -> {:ok, mirror_path}
        {output, _} -> {:error, String.trim(output)}
      end
    end
  end

  defp put_assignment(repo_id, params, node_payload) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()
    source_node_id = params["sourceNodeId"] || node_payload["sub"]
    target_node_id = TreeDb.Federation.NodeIdentity.node_id()

    TreeDb.Store.put_mirror_assignment(%{
      id: "mirror_#{repo_id}_#{source_node_id}_#{target_node_id}",
      repositoryId: repo_id,
      sourceNodeId: source_node_id,
      targetNodeId: target_node_id,
      mode: "git_bundle",
      promotionEligible: params["promotionEligible"] != false,
      freshnessRequirement: %{"maxStalenessMs" => max_staleness_ms()},
      status: "synced",
      lastSyncedCommit: latest_ref_sha(params["refs"]),
      lastSyncAt: now,
      createdAt: now
    })
  end

  defp update_route(repo_id, repository_name, params, assignment) do
    current =
      case TreeDb.Store.get_federation_route(repo_id) do
        {:ok, route} when is_map(route) -> route
        _ -> %{}
      end

    mirror_node_ids =
      current
      |> Map.get("mirrorNodeIds", [])
      |> Kernel.++([assignment["targetNodeId"]])
      |> Enum.uniq()

    TreeDb.Store.put_federation_route(%{
      repositoryId: repo_id,
      repositoryName: repository_name,
      primaryNodeId: params["sourceNodeId"] || current["primaryNodeId"],
      mirrorNodeIds: mirror_node_ids,
      readPolicy: "primary_or_healthy_mirror",
      writePolicy: "primary_proxy",
      ownerNodeId: params["sourceNodeId"] || current["ownerNodeId"],
      source: "mirror_import",
      confidence: "confirmed",
      freshness: %{"lastSyncAt" => assignment["lastSyncAt"]},
      catalogVersion: System.system_time(:millisecond),
      lastSeenAt: DateTime.utc_now() |> DateTime.to_iso8601(),
      expiresAt: nil
    })
  end

  defp latest_ref_sha(refs) when is_list(refs) do
    refs
    |> Enum.find_value(fn
      %{"sha" => sha} -> sha
      %{"target" => sha} -> sha
      _ -> nil
    end)
  end

  defp latest_ref_sha(_), do: nil

  defp sanitize_route(route),
    do: Map.take(route, ["repositoryId", "repositoryName", "primaryNodeId", "mirrorNodeIds"])

  defp max_staleness_ms,
    do:
      System.get_env("TREEDB_FEDERATION_MAX_MIRROR_STALENESS_MS", "30000") |> String.to_integer()

  defp git_error(reason),
    do: %{
      code: "federated_mirror_unavailable",
      message: "Mirror transfer failed.",
      details: %{reason: inspect(reason)}
    }

  defp sanitize_body(body) when is_binary(body), do: String.slice(body, 0, 512)
  defp sanitize_body(_), do: "Mirror import failed."
end
