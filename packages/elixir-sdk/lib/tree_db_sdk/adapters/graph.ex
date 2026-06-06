defmodule TreeDbSdk.Graph do
  @moduledoc false
  alias TreeDbSdk.Adapters.Common

  def refresh(client, repo_id, body \\ %{}) do
    Common.json_request(
      client,
      :post,
      "/api/v1/repos/" <> Common.segment(repo_id) <> "/graph/refresh",
      body,
      %{}
    )
  end

  def query(client, repo_id, body) do
    Common.json_request(
      client,
      :post,
      "/api/v1/repos/" <> Common.segment(repo_id) <> "/graph/query",
      body,
      %{}
    )
  end
end
