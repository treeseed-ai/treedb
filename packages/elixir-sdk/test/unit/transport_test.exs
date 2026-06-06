defmodule TreeDbSdk.TransportTest do
  use ExUnit.Case, async: true

  test "request defaults are empty" do
    request = %TreeDbSdk.Transport.Request{method: :get, path: "/api/v1/health"}
    assert request.query == %{}
    assert request.headers == %{}
    assert request.body == nil
  end
end
