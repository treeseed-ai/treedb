defmodule TreeDbSdk.RepositoriesAdapterTest do
  use ExUnit.Case, async: true

  test "register constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Repositories.register(client, %{})

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :post and &1.path == "/api/v1/repos/register")
           )
  end

  test "get constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Repositories.get(client, "repo/a")

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :get and &1.path == "/api/v1/repos/repo%2Fa")
           )
  end

  test "refs constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Repositories.refs(client, "repo/a")

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :get and &1.path == "/api/v1/repos/repo%2Fa/refs")
           )
  end
end
