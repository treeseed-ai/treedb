defmodule TreeDb.AuthTest do
  use ExUnit.Case, async: false

  setup do
    dir = Path.join(System.tmp_dir!(), "treedb-auth-test-#{System.unique_integer([:positive])}")
    Application.put_env(:treedb, :data_dir, dir)
    TreeDb.Store.init!(node_id: "node_local")
    {:ok, _} = TreeDb.Store.seed_dev_records("node_local", "http://localhost:4000")
    :ok
  end

  test "creates and resolves dev token" do
    {:ok, token} = TreeDb.Auth.create_dev_token(%{})
    assert token.accessToken =~ "treedb_dev_"
    assert {:ok, principal} = TreeDb.Auth.authenticate_token(token.accessToken)
    assert principal.actorId == "actor_demo"
  end

  test "expired dev token is rejected" do
    {:ok, token_hash} = TreeDb.Store.hash_token("expired")

    {:ok, _} =
      TreeDb.Store.put_dev_token(%{
        tokenHash: token_hash,
        actorId: "actor_demo",
        tenantId: "tenant_demo",
        expiresAt: DateTime.utc_now() |> DateTime.add(-1, :second) |> DateTime.to_iso8601(),
        createdAt: DateTime.utc_now() |> DateTime.to_iso8601()
      })

    assert {:error, %{code: "token_expired"}} = TreeDb.Auth.authenticate_token("expired")
  end
end
