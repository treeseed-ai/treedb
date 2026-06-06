defmodule TreeDbSdk.ClientTest do
  use ExUnit.Case, async: true

  test "client preserves config and custom transport" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    assert client.config.base_url == "http://localhost:4000"
    assert client.config.transport == {TreeDbSdk.Test.MockTransport, pid}
  end

  test "top-level health delegates through transport" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    assert {:ok, %{"ok" => true}} = TreeDbSdk.health(client)
    assert [%{path: "/api/v1/health"}] = TreeDbSdk.Test.MockTransport.requests(pid)
  end
end
