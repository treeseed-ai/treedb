defmodule TreeDbSdk.Conformance.Adapter do
  @moduledoc false
  defstruct [:client, server_configured: false]

  def new(client, opts \\ []),
    do: %__MODULE__{
      client: client,
      server_configured: Keyword.get(opts, :server_configured, false)
    }

  def run_scenario(%__MODULE__{server_configured: configured}, scenario) do
    message =
      if configured,
        do: "executable scenario dispatch is deferred to a later phase",
        else: "TreeDB server is not configured"

    %{scenario_id: scenario["id"], status: :not_configured, message: message}
  end
end
