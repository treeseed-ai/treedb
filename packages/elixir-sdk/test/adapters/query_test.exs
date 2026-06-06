defmodule TreeDbSdk.QueryAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Query.read_file(client, "repo/a", %{})
    TreeDbSdk.Query.list_paths(client, "repo/a", %{})
    TreeDbSdk.Query.search_files(client, "repo/a", %{})
    TreeDbSdk.Query.repository(client, "repo/a", %{})

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :post and &1.path == "/api/v1/repos/repo%2Fa/query")
           )
  end
end
