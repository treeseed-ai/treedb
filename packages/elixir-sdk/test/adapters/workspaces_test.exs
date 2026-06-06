defmodule TreeDbSdk.WorkspacesAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Workspaces.create(client, "repo/a", %{})
    TreeDbSdk.Workspaces.get(client, "ws/a")
    TreeDbSdk.Workspaces.close(client, "ws/a")

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :post and &1.path == "/api/v1/workspaces/ws%2Fa/close")
           )
  end
end
