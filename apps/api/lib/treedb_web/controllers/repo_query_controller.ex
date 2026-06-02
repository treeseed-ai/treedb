defmodule TreeDbWeb.RepoQueryController do
  use Phoenix.Controller, formats: [:json]
  import TreeDbWeb.ControllerHelpers

  def read(conn, %{"repo_id" => repo_id} = params),
    do: with_principal(conn, &TreeDb.RepositoryQuery.read(repo_id, params, &1))

  def paths(conn, %{"repo_id" => repo_id} = params),
    do: with_principal(conn, &TreeDb.RepositoryQuery.paths(repo_id, params, &1))

  def search(conn, %{"repo_id" => repo_id} = params),
    do: with_principal(conn, &TreeDb.RepositoryQuery.search(repo_id, params, &1))

  def query(conn, %{"repo_id" => repo_id} = params),
    do: with_principal(conn, &TreeDb.RepositoryQuery.query(repo_id, params, &1))

  defp with_principal(conn, fun) do
    with {:ok, principal} <- require_principal(conn) do
      handle_result(conn, fun.(principal))
    else
      {:error, error} -> error(conn, status_for(error[:code] || error["code"]), error)
    end
  end
end
