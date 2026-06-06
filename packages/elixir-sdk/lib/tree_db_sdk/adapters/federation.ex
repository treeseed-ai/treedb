defmodule TreeDbSdk.Federation do
  @moduledoc false
  alias TreeDbSdk.Adapters.Common

  def plan(client, body) do
    Common.json_request(client, :post, "/api/v1/federation/query/plan", body, %{})
  end

  def search(client, body) do
    Common.json_request(client, :post, "/api/v1/search", body, %{})
  end

  def query(client, body) do
    Common.json_request(client, :post, "/api/v1/query", body, %{})
  end

  def context_build(client, body) do
    Common.json_request(client, :post, "/api/v1/context/build", body, %{})
  end

  def graph_query(client, body) do
    Common.json_request(client, :post, "/api/v1/graph/query", body, %{})
  end
end
