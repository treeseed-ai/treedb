defmodule TreeDbSdk.FilesAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Files.tree(client, "ws/a")
    TreeDbSdk.Files.write(client, "ws/a", %{})
    TreeDbSdk.Files.patch(client, "ws/a", %{})
    TreeDbSdk.Files.delete(client, "ws/a")
    TreeDbSdk.Files.commit(client, "ws/a", %{})

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :post and &1.path == "/api/v1/workspaces/ws%2Fa/commit")
           )
  end
end
