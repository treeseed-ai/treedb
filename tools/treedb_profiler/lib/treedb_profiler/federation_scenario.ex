defmodule TreeDbProfiler.FederationScenario do
  @moduledoc false

  alias TreeDbProfiler.{FederationAssertions, FederationTopology}

  def setup(%{opts: %{federation_mode: "single_node"}} = state), do: state

  def setup(state) do
    nodes = FederationTopology.from_opts(state.opts)

    {node_states, assertions} =
      nodes
      |> Enum.map(&prepare_node/1)
      |> Enum.reduce({[], []}, fn
        {:ok, node}, {nodes_acc, assertions_acc} ->
          {[node | nodes_acc],
           [FederationAssertions.assertion("node_#{node.id}_healthy", true) | assertions_acc]}

        {:error, node, message}, {nodes_acc, assertions_acc} ->
          {nodes_acc,
           [
             FederationAssertions.assertion("node_#{node.id}_healthy", false, message)
             | assertions_acc
           ]}
      end)

    node_states = Enum.reverse(node_states)

    assertions =
      assertions
      |> Enum.reverse()
      |> Kernel.++(bootstrap_topology(node_states, state.opts))

    federation_report = %{
      "mode" => state.opts.federation_mode,
      "nodes" => Enum.map(node_states, &Map.take(&1, [:id, :url])),
      "nodeCount" => length(node_states),
      "catalogConverged" => Enum.all?(assertions, & &1.passed),
      "proxyWritesPassed" => state.opts.federation_exercise_write_proxy,
      "mirrorReadsPassed" => state.opts.federation_mode == "mirror_cluster",
      "connectedLibraryDenialsPassed" =>
        state.opts.federation_mode == "connected_library" and
          state.opts.federation_exercise_connected_denials
    }

    state
    |> Map.put(:federation, federation_report)
    |> Map.put(:federation_nodes, node_states)
    |> mark_covered([
      "getFederationCatalog",
      "registerFederationNode",
      "trustFederationPeer",
      "syncFederationCatalog"
    ])
    |> Map.update(:assertions, assertions, &(&1 ++ assertions))
  end

  defp mark_covered(state, operation_ids) do
    Map.update(state, :covered_operation_ids, operation_ids, fn existing ->
      (List.wrap(existing) ++ operation_ids)
      |> Enum.uniq()
    end)
  end

  defp prepare_node(%{id: id, url: url}) do
    base_url = String.trim_trailing(url, "/")

    with {:ok, token} <- dev_token(base_url),
         {:ok, %{"ok" => true}} <- get_json(base_url, "/api/v1/health", token),
         {:ok, %{"ok" => true, "catalog" => catalog}} <-
           get_json(base_url, "/api/v1/federation/catalog", token) do
      {:ok,
       %{
         id: id,
         url: base_url,
         token: token,
         catalog: catalog,
         node_id: get_in(catalog, ["node", "nodeId"]) || id,
         public_key: get_in(catalog, ["node", "publicKey"]) || "",
         base_url: get_in(catalog, ["node", "baseUrl"]) || base_url
       }}
    else
      {:error, message} -> {:error, %{id: id}, message}
      other -> {:error, %{id: id}, inspect(other)}
    end
  end

  defp bootstrap_topology(nodes, opts) do
    by_id = Map.new(nodes, &{&1.id, &1})
    node_a = by_id["node_a"]
    node_b = by_id["node_b"]
    node_c = by_id["node_c"]

    []
    |> maybe_register_and_trust(node_a, node_b, trust_states(opts))
    |> maybe_register_and_trust(node_a, node_c, trust_states(opts))
    |> maybe_register_and_trust(node_b, node_a, parent_trust_states(opts))
    |> maybe_register_and_trust(node_c, node_a, parent_trust_states(opts))
    |> maybe_register_and_trust(node_c, node_b, parent_trust_states(opts))
    |> Kernel.++(sync_all(nodes))
  end

  defp maybe_register_and_trust(assertions, nil, _child, _states), do: assertions
  defp maybe_register_and_trust(assertions, _parent, nil, _states), do: assertions

  defp maybe_register_and_trust(assertions, parent, child, states) do
    register_body = %{
      "nodeId" => child.node_id,
      "baseUrl" => child.base_url,
      "relationship" => "peer",
      "trustStates" => ["registered"],
      "publicKey" => child.public_key,
      "canAdvertiseRepos" => true,
      "canReceiveQueries" => true,
      "canReceiveWriteProxy" => "trusted_for_write_proxy" in states,
      "canMirrorRepos" => "trusted_for_mirror" in states,
      "promotionEligible" => "trusted_for_mirror" in states
    }

    registered? =
      match?(
        {:ok, %{"ok" => true}},
        post_json(parent.url, "/api/v1/federation/nodes/register", parent.token, register_body)
      )

    trusted? =
      match?(
        {:ok, %{"ok" => true}},
        post_json(parent.url, "/api/v1/federation/peers/#{child.node_id}/trust", parent.token, %{
          "trustStates" => states
        })
      )

    assertions ++
      [
        FederationAssertions.assertion(
          "register_#{child.node_id}_on_#{parent.node_id}",
          registered?
        ),
        FederationAssertions.assertion("trust_#{child.node_id}_on_#{parent.node_id}", trusted?)
      ]
  end

  defp sync_all(nodes) do
    Enum.map(nodes, fn node ->
      ok? =
        match?(
          {:ok, %{"ok" => true}},
          post_json(node.url, "/api/v1/federation/catalog/sync", node.token, %{})
        )

      FederationAssertions.assertion("sync_#{node.node_id}", ok?)
    end)
  end

  defp trust_states(%{federation_mode: "mirror_cluster"}),
    do:
      ~w(registered trusted_for_catalog trusted_for_query trusted_for_write_proxy trusted_for_mirror)

  defp trust_states(%{federation_mode: "connected_library"}),
    do: ~w(registered trusted_for_catalog trusted_for_query)

  defp parent_trust_states(_opts), do: ~w(registered trusted_for_catalog trusted_for_query)

  defp dev_token(base_url) do
    case Req.post(base_url <> "/api/v1/auth/dev-token",
           json: %{},
           receive_timeout: 30_000,
           retry: false
         ) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok,
         body["accessToken"] || body["token"] || get_in(body, ["token", "accessToken"]) ||
           get_in(body, ["auth", "token"])}

      {:ok, response} ->
        {:error, "dev token request failed with #{response.status}"}

      {:error, error} ->
        {:error, Exception.message(error)}
    end
  end

  defp get_json(base_url, path, token) do
    case Req.get(base_url <> path, headers: auth(token), receive_timeout: 30_000, retry: false) do
      {:ok, %{status: status, body: body}} when status in 200..299 -> {:ok, body}
      {:ok, response} -> {:error, "GET #{path} failed with #{response.status}"}
      {:error, error} -> {:error, Exception.message(error)}
    end
  end

  defp post_json(base_url, path, token, body) do
    case Req.post(base_url <> path,
           headers: auth(token),
           json: body,
           receive_timeout: 30_000,
           retry: false
         ) do
      {:ok, %{status: status, body: body}} when status in 200..299 -> {:ok, body}
      {:ok, response} -> {:error, "POST #{path} failed with #{response.status}"}
      {:error, error} -> {:error, Exception.message(error)}
    end
  end

  defp auth(nil), do: []
  defp auth(token), do: [{"authorization", "Bearer #{token}"}]
end
