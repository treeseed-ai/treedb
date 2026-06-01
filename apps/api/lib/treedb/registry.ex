defmodule TreeDb.Registry do
  @moduledoc false

  def node do
    node_id = System.get_env("TREEDB_NODE_ID") || "node_local"
    TreeDb.Store.get_node(node_id)
  end

  def nodes, do: TreeDb.Store.list_nodes()
  def placement(repo_id), do: TreeDb.Store.get_repository_placement(repo_id)
  def put_placement(input), do: TreeDb.Store.put_repository_placement(input)
  def mirrors(repo_id), do: TreeDb.Store.list_mirrors(repo_id)
  def put_mirror(input), do: TreeDb.Store.put_mirror(input)
end
