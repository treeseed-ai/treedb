defmodule TreeDbWeb.RepoControllerTest do
  use TreeDbWeb.ConnCase, async: false

  setup %{conn: conn} do
    token_conn = post(conn, "/api/v1/auth/dev-token", %{})
    token = json_response(token_conn, 200)["accessToken"]
    {:ok, token: token}
  end

  test "register rejects missing token", %{conn: conn} do
    conn =
      post(conn, "/api/v1/repos/register", %{
        "name" => "demo",
        "localPath" => Path.join(TreeDb.Store.data_dir(), "repos/bare/demo.git")
      })

    assert json_response(conn, 401)["error"]["code"] == "authentication_required"
  end

  test "registers, lists, and returns status", %{token: token} do
    path = Path.join(TreeDb.Store.data_dir(), "repos/bare/controller-demo.git")

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/api/v1/repos/register", %{"name" => "controller-demo", "localPath" => path})

    repo_id = json_response(conn, 200)["repo"]["repoId"]

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/api/v1/repos")

    assert Enum.any?(json_response(conn, 200)["repos"], &(&1["repoId"] == repo_id))

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/api/v1/repos/#{repo_id}/status")

    assert json_response(conn, 200)["git"]["exists"] == false
  end
end
