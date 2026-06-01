defmodule TreeDbWeb.HealthControllerTest do
  use TreeDbWeb.ConnCase, async: false

  test "health and version endpoints", %{conn: conn} do
    conn = get(conn, "/api/v1/health")
    assert json_response(conn, 200)["status"] == "ok"

    conn = get(build_conn(), "/api/v1/version")
    assert json_response(conn, 200)["version"] == "0.1.0"
  end
end
