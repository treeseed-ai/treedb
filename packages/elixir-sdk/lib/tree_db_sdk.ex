defmodule TreeDbSdk do
  @moduledoc "Generic Elixir SDK facade for TreeDB."

  defdelegate health(client), to: TreeDbSdk.Client
  defdelegate version(client), to: TreeDbSdk.Client
  defdelegate whoami(client), to: TreeDbSdk.Client
  defdelegate effective_scope(client), to: TreeDbSdk.Client
end
