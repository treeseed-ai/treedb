defmodule TreeDbSdk.ObservabilityAdapterTest do
  use ExUnit.Case, async: true

  test "all constructs expected request" do
    {:ok, pid} = TreeDbSdk.Test.MockTransport.start_link()
    client = TreeDbSdk.Test.MockTransport.client(pid)
    TreeDbSdk.Observability.health(client)
    TreeDbSdk.Observability.ready(client)
    TreeDbSdk.Observability.deep_health(client)
    TreeDbSdk.Observability.metrics(client)

    assert Enum.any?(
             TreeDbSdk.Test.MockTransport.requests(pid),
             &(&1.method == :get and &1.path == "/api/v1/metrics")
           )
  end
end
