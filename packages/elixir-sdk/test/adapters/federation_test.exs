defmodule TreeDbSdk.FederationAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Federation.plan(client, %{})
    TreeDbSdk.Federation.search(client, %{})
    TreeDbSdk.Federation.query(client, %{})
    TreeDbSdk.Federation.context_build(client, %{})
    TreeDbSdk.Federation.graph_query(client, %{})

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :post and &1.path == "/api/v1/graph/query")
           )
  end
end
