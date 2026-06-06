defmodule TreeDbSdk.LiveApiTest do
  use ExUnit.Case, async: true

  test "live health is optional" do
    case System.get_env("TREEDB_BASE_URL") do
      nil ->
        assert true

      base_url ->
        client = TreeDbSdk.Client.new(base_url: base_url, token: System.get_env("TREEDB_TOKEN"))
        assert {:ok, _} = TreeDbSdk.health(client)
    end
  end
end
