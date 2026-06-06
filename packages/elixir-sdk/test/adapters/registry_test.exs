defmodule TreeDbSdk.RegistryAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Registry.local_node(client)
    TreeDbSdk.Registry.nodes(client)
    TreeDbSdk.Registry.get_placement(client, "repo/a")
    TreeDbSdk.Registry.set_placement(client, "repo/a", %{})

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :post and &1.path == "/api/v1/registry/repos/repo%2Fa/placement")
           )
  end
end
