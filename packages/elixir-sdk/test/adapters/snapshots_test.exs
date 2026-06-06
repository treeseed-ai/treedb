defmodule TreeDbSdk.SnapshotsAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Snapshots.build(client, "repo/a", %{})
    TreeDbSdk.Snapshots.get(client, "repo/a", "snap/a")

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :get and &1.path == "/api/v1/repos/repo%2Fa/snapshots/snap%2Fa")
           )
  end
end
