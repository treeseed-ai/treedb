defmodule TreeDb.Repos do
  @moduledoc false

  def register(params, principal) do
    with {:ok, _scope} <- TreeDb.Capabilities.require_capability(principal, "repos:write", nil),
         {:ok, input} <- normalize_registration(params),
         {:ok, repo} <- TreeDb.Store.put_repository(input),
         {:ok, placement} <- ensure_placement(repo) do
      TreeDb.Audit.append("repo.registered", %{
        actor_id: principal["actorId"],
        tenant_id: principal["tenantId"],
        repo_id: repo["id"],
        data: %{name: repo["name"]}
      })

      {:ok, %{repo: public_repo(repo), placement: public_placement(placement)}}
    end
  end

  def list(principal) do
    with {:ok, _scope} <- TreeDb.Capabilities.require_capability(principal, "repos:read", nil) do
      with {:ok, repos} <- TreeDb.Store.list_repositories() do
        {:ok, Enum.map(repos, &public_repo/1)}
      end
    end
  end

  def get(repo_id, principal) do
    with {:ok, _scope} <-
           TreeDb.Capabilities.require_capability(principal, "repos:read", repo_id),
         {:ok, repo} when is_map(repo) <- TreeDb.Store.get_repository(repo_id) do
      {:ok, public_repo(repo)}
    else
      {:ok, nil} -> {:error, %{code: "not_found", message: "Repository not found."}}
      other -> other
    end
  end

  def status(repo_id, principal) do
    with {:ok, _scope} <-
           TreeDb.Capabilities.require_capability(principal, "repos:read", repo_id),
         {:ok, repo} when is_map(repo) <- TreeDb.Store.get_repository(repo_id),
         {:ok, git} <- TreeDb.Git.inspect_repository(repo["localPath"]),
         {:ok, placement} <- TreeDb.Store.get_repository_placement(repo_id) do
      TreeDb.Audit.append("repo.status_inspected", %{
        actor_id: principal["actorId"],
        tenant_id: principal["tenantId"],
        repo_id: repo_id
      })

      {:ok, %{repo: public_repo(repo), git: git, placement: placement}}
    else
      {:ok, nil} -> {:error, %{code: "not_found", message: "Repository not found."}}
      other -> other
    end
  end

  defp normalize_registration(params) do
    name = params["name"]
    local_path = params["localPath"]
    data_dir = Path.expand(TreeDb.Store.data_dir())

    cond do
      !is_binary(name) or String.trim(name) == "" ->
        {:error, %{code: "validation_error", message: "name is required."}}

      !is_binary(local_path) or String.trim(local_path) == "" ->
        {:error, %{code: "validation_error", message: "localPath is required."}}

      Path.type(local_path) != :absolute ->
        {:error, %{code: "validation_error", message: "localPath must be absolute."}}

      !String.starts_with?(Path.expand(local_path), data_dir) ->
        {:error, %{code: "validation_error", message: "localPath must be under TREEDB_DATA_DIR."}}

      true ->
        {:ok,
         %{
           name: name,
           localPath: Path.expand(local_path),
           defaultRef: params["defaultRef"] || "refs/heads/main",
           remoteUrl: params["remoteUrl"]
         }}
    end
  end

  defp ensure_placement(repo) do
    input = %{
      repositoryId: repo["id"],
      primaryNodeId: System.get_env("TREEDB_NODE_ID") || "node_local",
      mirrorNodeIds: [],
      readPolicy: "primary_or_mirror",
      writePolicy: "primary_only",
      migrationState: "stable"
    }

    TreeDb.Store.put_repository_placement(input)
  end

  defp public_repo(repo) do
    %{
      repoId: repo["id"],
      name: repo["name"],
      defaultRef: repo["defaultRef"],
      status: repo["status"],
      localPath: repo["localPath"],
      remoteUrl: repo["remoteUrl"]
    }
  end

  defp public_placement(nil), do: nil
  defp public_placement(placement), do: %{"primaryNodeId" => placement["primaryNodeId"]}
end
