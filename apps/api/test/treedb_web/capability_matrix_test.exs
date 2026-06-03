defmodule TreeDbWeb.CapabilityMatrixTest do
  use TreeDbWeb.ConnCase, async: false

  test "protected endpoints require authentication and capability", %{conn: conn} do
    data_dir = TreeDb.Store.data_dir()
    repo_path = Path.join(data_dir, "repos/bare/capability-matrix-repo")
    create_git_repo!(repo_path)
    admin_token = dev_token!(conn)

    repo_id =
      register_repo!(build_conn(), admin_token, %{
        "name" => "capability-matrix-repo",
        "localPath" => repo_path
      })["repo"]["repoId"]

    unauthenticated = get(build_conn(), "/api/v1/repos/#{repo_id}")
    assert json_response(unauthenticated, 401)["error"]["code"] == "authentication_required"

    {:ok, _grant} =
      TreeDb.Capabilities.put_grant(%{
        "actorId" => "actor_readonly",
        "tenantId" => "tenant_demo",
        "repoIds" => [repo_id],
        "capabilities" => ["repos:read"],
        "refs" => ["refs/heads/main"],
        "paths" => ["docs/**"]
      })

    readonly_token =
      dev_token!(build_conn(), %{"actorId" => "actor_readonly", "tenantId" => "tenant_demo"})

    denied =
      build_conn()
      |> auth_conn(readonly_token)
      |> post("/api/v1/repos/#{repo_id}/files/search", %{
        "ref" => "refs/heads/main",
        "paths" => ["docs/**"],
        "query" => "mvp provenance"
      })
      |> json!(403)

    assert denied["error"]["code"] == "permission_denied"
  end
end
