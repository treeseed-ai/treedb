defmodule TreeDb.Federation.Proxy do
  @moduledoc false

  @proxyable_methods ~w(GET POST PUT PATCH DELETE)

  def maybe_proxy_repo_read(repo_id, conn, body \\ nil),
    do: maybe_proxy_repo(repo_id, conn, body, :read)

  def maybe_proxy_repo_write(repo_id, conn, body \\ nil),
    do: maybe_proxy_repo(repo_id, conn, body, :write)

  def maybe_proxy_repo(repo_id, conn, body \\ nil, mode \\ :write) do
    if internal_dispatch?(conn) do
      :local
    else
      with {:ok, route} <- TreeDb.Federation.RouteTable.resolve_repo(repo_id, mode: mode) do
        case route["source"] do
          "local" -> :local
          "mirror" -> :local
          _ -> forward(conn, route, body)
        end
      else
        {:error, %{code: "federated_route_not_configured"}} -> :local
        {:error, %{"code" => "federated_route_not_configured"}} -> :local
        other -> other
      end
    end
  end

  def maybe_proxy_workspace(workspace_id, conn, body \\ nil) do
    if internal_dispatch?(conn) do
      :local
    else
      with {:ok, route} <- TreeDb.Federation.RouteTable.resolve_workspace(workspace_id) do
        case route["source"] do
          "local" -> :local
          _ -> forward(conn, route, body)
        end
      end
    end
  end

  def route_required(repo_id), do: {:error, write_route_required(repo_id)}

  def proxy_response?(result), do: match?({:proxy, _, _, _}, result)

  defp forward(conn, route, body) do
    method = conn.method

    cond do
      method not in @proxyable_methods ->
        {:error,
         %{code: "federated_route_not_configured", message: "HTTP method cannot be proxied."}}

      hop(conn) >= max_hops() ->
        {:error, %{code: "federated_proxy_loop", message: "Federated proxy hop limit reached."}}

      !is_binary(route["baseUrl"]) or route["baseUrl"] == "" ->
        {:error,
         %{code: "federated_route_not_configured", message: "Federated route is not configured."}}

      true ->
        do_forward(conn, route, body)
    end
  end

  defp do_forward(conn, route, body) do
    target_node_id = route["servedByNodeId"] || route["primaryNodeId"] || route["nodeId"]
    payload = proxy_payload(conn, body, target_node_id)

    case TreeDb.Federation.HttpClient.post_json(
           target_node_id,
           route["baseUrl"],
           "/api/v1/internal/federation/proxy",
           "proxy",
           payload
         ) do
      {:ok, status, _headers, response_body} when status in 200..299 ->
        unwrap_proxy_response(response_body)

      {:ok, status, _headers, response_body} ->
        {:proxy, status, [], response_body}

      {:error, error} ->
        {:error, error}
    end
  end

  defp proxy_payload(conn, body, target_node_id) do
    request_id = conn.assigns[:request_id] || "req_#{System.unique_integer([:positive])}"
    body = body || conn.assigns[:raw_body] || conn.body_params || %{}
    {body_encoding, encoded_body} = encode_body(body)

    %{
      method: conn.method,
      path: conn.request_path,
      queryString: conn.query_string || "",
      headers: forwarded_headers(conn),
      body: encoded_body,
      bodyEncoding: body_encoding,
      originalRequestId: request_id,
      idempotencyKey: idempotency_key(conn, target_node_id)
    }
  end

  defp unwrap_proxy_response(response_body) do
    with {:ok, %{"status" => status, "headers" => headers, "body" => encoded_body}} <-
           Jason.decode(response_body),
         {:ok, decoded_body} <- Base.decode64(encoded_body || "") do
      {:proxy, status, headers || [], decoded_body}
    else
      _ -> {:error, %{code: "federated_node_unavailable", message: "Invalid proxy response."}}
    end
  end

  defp forwarded_headers(conn) do
    conn.req_headers
    |> Enum.reject(fn {key, _value} ->
      key in [
        "host",
        "content-length",
        "x-treedb-node-authorization",
        "x-treedb-internal-dispatch"
      ]
    end)
    |> Map.new()
    |> Map.put("x-treedb-original-request-id", conn.assigns[:request_id] || "")
    |> Map.put("x-treedb-forwarded-by", TreeDb.Federation.NodeIdentity.node_id())
    |> Map.put("x-treedb-forward-hop", "#{hop(conn) + 1}")
  end

  defp encode_body(body) when is_binary(body), do: {"base64", Base.encode64(body)}
  defp encode_body(body), do: {"json", body || %{}}

  defp idempotency_key(conn, target_node_id) do
    case Plug.Conn.get_req_header(conn, "x-treedb-idempotency-key") do
      [key | _] ->
        key

      _ ->
        body_hash =
          :crypto.hash(:sha256, inspect(conn.body_params || conn.assigns[:raw_body] || ""))
          |> Base.url_encode64(padding: false)

        "idem_#{target_node_id}_#{conn.method}_#{conn.request_path}_#{body_hash}"
    end
  end

  defp internal_dispatch?(conn) do
    Plug.Conn.get_req_header(conn, "x-treedb-internal-dispatch") == ["true"]
  end

  defp max_hops,
    do: System.get_env("TREEDB_FEDERATION_WRITE_PROXY_MAX_HOPS", "1") |> String.to_integer()

  defp hop(conn) do
    case Plug.Conn.get_req_header(conn, "x-treedb-forward-hop") do
      [value | _] ->
        case Integer.parse(value) do
          {int, ""} -> int
          _ -> 0
        end

      _ ->
        0
    end
  end

  defp write_route_required(repo_id) do
    primary =
      case TreeDb.Federation.RouteTable.resolve(repo_id) do
        {:ok, route} -> route["primaryNodeId"]
        _ -> nil
      end

    %{
      code: "write_route_required",
      message: "Repository writes must be sent to the primary node.",
      details: %{repoId: repo_id, primaryNodeId: primary}
    }
  end
end
