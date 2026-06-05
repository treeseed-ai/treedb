defmodule TreeDb.Federation.NodeAuth do
  @moduledoc false

  @token_ttl_seconds 60

  def issue(operation, target_node_id, opts \\ []) do
    now = System.system_time(:second)

    payload =
      %{
        "iss" => "treedb-node:#{TreeDb.Federation.NodeIdentity.node_id()}",
        "sub" => TreeDb.Federation.NodeIdentity.node_id(),
        "aud" => target_node_id,
        "iat" => now,
        "exp" => now + Keyword.get(opts, :ttl_seconds, @token_ttl_seconds),
        "jti" => Keyword.get(opts, :jti, "node_req_#{System.unique_integer([:positive])}"),
        "treedb_node_id" => TreeDb.Federation.NodeIdentity.node_id(),
        "treedb_operation" => to_string(operation),
        "treedb_request_id" =>
          Keyword.get(opts, :request_id, "req_#{System.unique_integer([:positive])}")
      }

    encoded_payload =
      payload
      |> Jason.encode!()
      |> Base.url_encode64(padding: false)

    signature = TreeDb.Federation.NodeIdentity.sign_binary(encoded_payload)
    encoded_payload <> "." <> signature
  end

  def authorization_header(operation, target_node_id, opts \\ []) do
    {"x-treedb-node-authorization", "Bearer " <> issue(operation, target_node_id, opts)}
  end

  def verify_conn(conn, operation) do
    conn
    |> Plug.Conn.get_req_header("x-treedb-node-authorization")
    |> List.first()
    |> verify(operation)
  end

  def verify("Bearer " <> token, operation), do: verify(token, operation)

  def verify(token, operation) when is_binary(token) do
    with [encoded_payload, signature] <- String.split(token, ".", parts: 2),
         {:ok, payload_json} <- Base.url_decode64(encoded_payload, padding: false),
         {:ok, payload} <- Jason.decode(payload_json),
         :ok <- validate_payload(payload, operation),
         {:ok, public_key} <- peer_public_key(payload["sub"]),
         true <-
           TreeDb.Federation.NodeIdentity.verify_binary(encoded_payload, signature, public_key),
         :ok <- enforce_trust(payload["sub"], operation),
         :ok <- record_replay(payload["jti"], payload["exp"]) do
      {:ok, payload}
    else
      false -> {:error, error("federated_node_auth_invalid", "Invalid federated node token.")}
      {:error, error} when is_map(error) -> {:error, error}
      _ -> {:error, error("federated_node_auth_invalid", "Invalid federated node token.")}
    end
  end

  def verify(_, _),
    do: {:error, error("federated_node_auth_required", "Federated node auth is required.")}

  defp validate_payload(payload, operation) do
    now = System.system_time(:second)

    cond do
      payload["aud"] != TreeDb.Federation.NodeIdentity.node_id() ->
        {:error, error("federated_node_auth_invalid", "Federated node token audience mismatch.")}

      payload["exp"] in [nil, ""] or payload["exp"] < now ->
        {:error, error("federated_node_auth_invalid", "Federated node token expired.")}

      payload["treedb_operation"] != to_string(operation) ->
        {:error, error("federated_node_auth_forbidden", "Federated node operation mismatch.")}

      payload["sub"] in [nil, ""] or payload["jti"] in [nil, ""] ->
        {:error, error("federated_node_auth_invalid", "Federated node token is incomplete.")}

      true ->
        :ok
    end
  end

  defp peer_public_key(node_id) do
    if node_id == TreeDb.Federation.NodeIdentity.node_id() do
      {:ok, TreeDb.Federation.NodeIdentity.public_key_pem()}
    else
      with {:ok, peer} when is_map(peer) <- TreeDb.Store.get_federation_peer(node_id),
           public_key when is_binary(public_key) and public_key != "" <- peer["publicKeyPem"] do
        {:ok, public_key}
      else
        _ ->
          {:error,
           error("federated_node_auth_forbidden", "Federated peer is not trusted by this node.")}
      end
    end
  end

  defp enforce_trust(node_id, "health") do
    if node_id == TreeDb.Federation.NodeIdentity.node_id() or
         TreeDb.Federation.Trust.trusted?(node_id, "trusted_for_catalog") or
         registered?(node_id) do
      :ok
    else
      forbidden()
    end
  end

  defp enforce_trust(node_id, "catalog_sync"), do: require_state(node_id, "trusted_for_catalog")
  defp enforce_trust(node_id, "mirror_export"), do: require_state(node_id, "trusted_for_mirror")
  defp enforce_trust(node_id, "mirror_import"), do: require_state(node_id, "trusted_for_mirror")

  defp enforce_trust(node_id, "proxy") do
    if TreeDb.Federation.Trust.trusted?(node_id, "trusted_for_write_proxy") or
         TreeDb.Federation.Trust.trusted?(node_id, "trusted_for_query") do
      :ok
    else
      forbidden()
    end
  end

  defp enforce_trust(node_id, _operation), do: require_state(node_id, "trusted_for_catalog")

  defp require_state(node_id, state) do
    if TreeDb.Federation.Trust.trusted?(node_id, state), do: :ok, else: forbidden()
  end

  defp registered?(node_id) do
    with {:ok, peer} when is_map(peer) <- TreeDb.Store.get_federation_peer(node_id) do
      is_nil(peer["blockedAt"]) and "registered" in (peer["trustStates"] || [])
    else
      _ -> false
    end
  end

  defp record_replay(jti, exp) do
    id = "node-jti:#{jti}"

    case TreeDb.Store.get_idempotency_record(id) do
      {:ok, record} when is_map(record) ->
        {:error, error("federated_node_auth_invalid", "Federated node token was replayed.")}

      _ ->
        TreeDb.Store.put_idempotency_record(%{
          id: id,
          method: "NODE",
          path: "node-auth",
          bodyHash: "",
          status: "seen",
          responseJson: %{},
          createdAt: DateTime.utc_now() |> DateTime.to_iso8601(),
          expiresAt: DateTime.from_unix!(exp) |> DateTime.to_iso8601()
        })

        :ok
    end
  end

  defp forbidden,
    do:
      {:error,
       error("federated_node_auth_forbidden", "Federated node is not trusted for this operation.")}

  defp error(code, message), do: %{code: code, message: message}
end
