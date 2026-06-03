defmodule TreeDbWeb.AdminStorageControllerTest do
  use TreeDbWeb.ConnCase, async: false

  test "admin storage endpoints are protected and redact paths", %{conn: conn} do
    token = dev_token!(conn)

    unauthorized = get(build_conn(), "/api/v1/admin/storage/health")
    assert json_response(unauthorized, 401)["error"]["code"] == "authentication_required"

    health =
      build_conn()
      |> auth_conn(token)
      |> get("/api/v1/admin/storage/health")
      |> json!(200)

    assert health["storage"]["dataDir"] == "redacted"
    assert health["storage"]["nativeLoaded"] == true
    assert_public_hygiene!(health)

    check =
      build_conn()
      |> auth_conn(token)
      |> post("/api/v1/admin/storage/check", %{})
      |> json!(200)

    assert check["check"]["status"] == "ok"
    assert_public_hygiene!(check)

    recover =
      build_conn()
      |> auth_conn(token)
      |> post("/api/v1/admin/storage/recover", %{"force" => true})
      |> json!(200)

    assert recover["recovered"] == false
  end
end
