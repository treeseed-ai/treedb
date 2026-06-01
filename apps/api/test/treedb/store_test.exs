defmodule TreeDb.StoreTest do
  use ExUnit.Case, async: false

  test "init initializes data dir" do
    dir = Path.join(System.tmp_dir!(), "treedb-store-test-#{System.unique_integer([:positive])}")
    Application.put_env(:treedb, :data_dir, dir)
    report = TreeDb.Store.init!(node_id: "node_local")
    assert File.dir?(Path.join(dir, "repos/bare"))
    assert report["manifestPath"] =~ "manifest.tdb"
  end
end
