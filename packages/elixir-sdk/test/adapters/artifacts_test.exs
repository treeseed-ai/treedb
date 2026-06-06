defmodule TreeDbSdk.ArtifactsAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Artifacts.export(client, "repo/a", %{})
    TreeDbSdk.Artifacts.list(client, "repo/a")
    TreeDbSdk.Artifacts.get(client, "repo/a", "art/a")
    TreeDbSdk.Artifacts.delete(client, "repo/a", "art/a")

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :delete and &1.path == "/api/v1/repos/repo%2Fa/artifacts/art%2Fa")
           )
  end
end
