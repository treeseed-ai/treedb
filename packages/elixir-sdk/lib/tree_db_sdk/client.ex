defmodule TreeDbSdk.Client do
  @moduledoc false
  defstruct [:config]

  def new(opts) do
    %__MODULE__{
      config: %TreeDbSdk.Config{
        base_url: Keyword.get(opts, :base_url),
        token: Keyword.get(opts, :token),
        auth_provider: Keyword.get(opts, :auth_provider),
        transport: Keyword.get(opts, :transport),
        default_headers: Keyword.get(opts, :default_headers, %{}),
        timeout: Keyword.get(opts, :timeout)
      }
    }
  end

  def health(client), do: TreeDbSdk.Observability.health(client)
  def version(client), do: TreeDbSdk.Adapters.Common.json_request(client, :get, "/api/v1/version")

  def whoami(client),
    do: TreeDbSdk.Adapters.Common.json_request(client, :get, "/api/v1/auth/whoami")

  def effective_scope(client),
    do: TreeDbSdk.Adapters.Common.json_request(client, :get, "/api/v1/policy/effective-scope")
end
