defmodule TreeDbSdk.Exec do
  @moduledoc false
  alias TreeDbSdk.Adapters.Common

  def run(client, workspace_id, body) do
    Common.json_request(
      client,
      :post,
      "/api/v1/workspaces/" <> Common.segment(workspace_id) <> "/exec",
      body,
      %{}
    )
  end
end
