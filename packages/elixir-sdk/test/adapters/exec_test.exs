defmodule TreeDbSdk.ExecAdapterTest do
  use ExUnit.Case, async: true

  test "run constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Exec.run(client, "ws/a", %{})

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :post and &1.path == "/api/v1/workspaces/ws%2Fa/exec")
           )
  end
end
