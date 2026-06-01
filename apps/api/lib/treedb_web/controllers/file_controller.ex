defmodule TreeDbWeb.FileController do
  use Phoenix.Controller, formats: [:json]
  import TreeDbWeb.ControllerHelpers

  def tree(conn, %{"workspace_id" => workspace_id} = params),
    do: with_principal(conn, &TreeDb.Files.tree(workspace_id, params, &1))

  def read(conn, %{"workspace_id" => workspace_id} = params),
    do: with_principal(conn, &TreeDb.Files.read(workspace_id, params, &1))

  def write(conn, %{"workspace_id" => workspace_id} = params),
    do: with_principal(conn, &TreeDb.Files.write(workspace_id, params, &1))

  def patch(conn, %{"workspace_id" => workspace_id} = params),
    do: with_principal(conn, &TreeDb.Files.patch(workspace_id, params, &1))

  def delete(conn, %{"workspace_id" => workspace_id} = params),
    do: with_principal(conn, &TreeDb.Files.delete(workspace_id, params, &1))

  def search(conn, %{"workspace_id" => workspace_id} = params),
    do: with_principal(conn, &TreeDb.Files.search(workspace_id, params, &1))

  def status(conn, %{"workspace_id" => workspace_id} = params),
    do: with_principal(conn, &TreeDb.Files.status(workspace_id, params, &1))

  def diff(conn, %{"workspace_id" => workspace_id} = params),
    do: with_principal(conn, &TreeDb.Files.diff(workspace_id, params, &1))

  def commit(conn, %{"workspace_id" => workspace_id} = params),
    do: with_principal(conn, &TreeDb.Files.commit(workspace_id, params, &1))

  defp with_principal(conn, fun) do
    with {:ok, principal} <- require_principal(conn) do
      handle_result(conn, fun.(principal))
    else
      {:error, error} -> error(conn, status_for(error[:code] || error["code"]), error)
    end
  end
end
