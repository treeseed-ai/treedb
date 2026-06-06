defmodule TreeDbSdk.BinaryTest do
  use ExUnit.Case, async: true

  test "binary helpers accept binaries and iodata" do
    assert TreeDbSdk.Binary.binary_body?("abc")
    assert TreeDbSdk.Binary.to_binary(["a", "b"]) == "ab"
  end

  test "binary helpers reject maps" do
    refute TreeDbSdk.Binary.binary_body?(%{})
    assert_raise ArgumentError, fn -> TreeDbSdk.Binary.assert_binary_body!(%{}) end
  end
end
