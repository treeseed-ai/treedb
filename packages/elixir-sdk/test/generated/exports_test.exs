defmodule TreeDbSdk.Generated.ExportsTest do
  use ExUnit.Case, async: true

  test "public modules compile" do
    assert is_list(TreeDbSdk.Generated.OpenApiTypes.operations())
    assert %TreeDbSdk.Error{} = TreeDbSdk.Error.network("offline")
    client = TreeDbSdk.Client.new(base_url: "http://localhost:4000")
    assert %TreeDbSdk.Conformance.Adapter{} = TreeDbSdk.Conformance.Adapter.new(client)
  end
end
