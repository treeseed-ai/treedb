defmodule TreeDbSdk.Adapters.Common do
  @moduledoc false

  def segment(value), do: URI.encode(to_string(value), &URI.char_unreserved?/1)

  def json_request(client, method, path, body \\ nil, query \\ %{}) do
    request = %TreeDbSdk.Transport.Request{
      method: method,
      path: path,
      body: body,
      query: query || %{}
    }

    dispatch(client, request)
  end

  def binary_request(client, method, path, binary_body, query \\ %{}) do
    request = %TreeDbSdk.Transport.Request{
      method: method,
      path: path,
      binary_body: binary_body,
      query: query || %{}
    }

    dispatch(client, request)
  end

  defp dispatch(%TreeDbSdk.Client{config: config}, request) do
    case config.transport do
      nil -> unwrap(TreeDbSdk.Transport.Httpc.request(config, request))
      module when is_atom(module) -> unwrap(module.request(config, request))
      {module, state} -> unwrap(module.request(state, config, request))
    end
  end

  defp unwrap({:ok, %TreeDbSdk.Transport.Response{data: data}}), do: {:ok, data}
  defp unwrap({:error, error}), do: {:error, error}
end
