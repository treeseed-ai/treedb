defmodule TreeDbSdk.MigrationsAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Migrations.create(client, "repo/a", %{})
    TreeDbSdk.Migrations.get(client, "repo/a", "mig/a")

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :get and &1.path == "/api/v1/repos/repo%2Fa/migrations/mig%2Fa")
           )
  end
end
