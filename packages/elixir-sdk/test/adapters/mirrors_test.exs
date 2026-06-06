defmodule TreeDbSdk.MirrorsAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Mirrors.list(client, "repo/a")
    TreeDbSdk.Mirrors.upsert(client, "repo/a", %{})
    TreeDbSdk.Mirrors.sync(client, "repo/a", "mir/a")
    TreeDbSdk.Mirrors.health(client, "repo/a", "mir/a")
    TreeDbSdk.Mirrors.promote(client, "repo/a", "mir/a")

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :post and &1.path == "/api/v1/repos/repo%2Fa/mirrors/mir%2Fa/promote")
           )
  end
end
