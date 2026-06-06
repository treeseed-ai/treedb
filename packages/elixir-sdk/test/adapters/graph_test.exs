defmodule TreeDbSdk.GraphAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Graph.refresh(client, "repo/a")
    TreeDbSdk.Graph.query(client, "repo/a", %{})

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :post and &1.path == "/api/v1/repos/repo%2Fa/graph/query")
           )
  end
end
