defmodule TreeDbSdk.Generated.OpenApiTypesTest do
  use ExUnit.Case, async: true

  test "operation count matches OpenAPI baseline" do
    assert TreeDbSdk.Generated.OpenApiTypes.operation_count() == 113
    assert length(TreeDbSdk.Generated.OpenApiTypes.operations()) == 113
  end
end
