defmodule TreeDbSdk.AuthTest do
  use ExUnit.Case, async: true

  test "static bearer auth resolves authorization header" do
    config = %TreeDbSdk.Config{token: "secret"}

    assert {:ok, {"Authorization", "Bearer secret"}} =
             TreeDbSdk.Auth.resolve_authorization_header(config)
  end
end
