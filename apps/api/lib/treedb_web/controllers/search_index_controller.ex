defmodule TreeDbWeb.SearchIndexController do
  use Phoenix.Controller, formats: [:json]
  import TreeDbWeb.ControllerHelpers

  def refresh(conn, %{"repo_id" => repo_id} = params),
    do: with_principal(conn, &TreeDb.Search.Index.refresh(repo_id, params, &1))

  def status(conn, %{"repo_id" => repo_id} = params),
    do: with_principal(conn, &TreeDb.Search.Index.status(repo_id, params, &1))

  def compact(conn, %{"repo_id" => repo_id} = params),
    do: with_principal(conn, &TreeDb.Search.Index.compact(repo_id, params, &1))

  defp with_principal(conn, fun) do
    with {:ok, principal} <- require_principal(conn) do
      handle_result(conn, fun.(principal))
    else
      {:error, error} -> error(conn, status_for(error[:code] || error["code"]), error)
    end
  end
end
