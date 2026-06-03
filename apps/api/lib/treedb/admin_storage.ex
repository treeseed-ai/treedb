defmodule TreeDb.AdminStorage do
  @moduledoc false

  @known_logs [
    "catalog/manifest.tdb",
    "catalog/repositories.tdb",
    "catalog/capability_grants.tdb",
    "catalog/policy_refreshes.tdb",
    "workspaces/sessions.tdb",
    "leases/leases.tdb",
    "audit/events.tdb",
    "federation/placements.tdb",
    "federation/mirrors/mirrors.tdb",
    "federation/migrations/migrations.tdb"
  ]

  def health do
    data_dir = TreeDb.Store.data_dir()

    {:ok,
     %{
       storage: %{
         dataDir: "redacted",
         mode: storage_mode(),
         lockHeld: File.exists?(Path.join(data_dir, ".treedb.lock")),
         manifestPresent: File.exists?(Path.join(data_dir, "catalog/manifest.tdb")),
         replayOk: check_status(data_dir) == "ok",
         nativeLoaded: Code.ensure_loaded?(TreeDb.Native)
       }
     }}
  end

  def check do
    data_dir = TreeDb.Store.data_dir()
    errors = collect_errors(data_dir)
    records_checked = count_records(data_dir)

    {:ok,
     %{
       check: %{
         status: if(errors == [], do: "ok", else: "error"),
         filesChecked: length(@known_logs),
         recordsChecked: records_checked,
         errors: errors
       }
     }}
  end

  def recover(params, principal, request_id) do
    force = params["force"] in [true, "true"]

    if storage_mode() == "read_only_recovery" or force do
      with {:ok, result} <- check() do
        TreeDb.Audit.append("storage.recovery_checked", %{
          actor_id: principal["actorId"],
          tenant_id: principal["tenantId"],
          operation: "storage.recover",
          status: "ok",
          request_id: request_id,
          data: %{status: result.check.status}
        })

        {:ok, Map.put(result, :recovered, false)}
      end
    else
      {:error,
       %{
         code: "conflict",
         message: "Storage recovery requires read_only_recovery mode or force=true."
       }}
    end
  end

  def storage_mode, do: System.get_env("TREEDB_STORAGE_MODE") || "read_write"

  defp check_status(data_dir), do: if(collect_errors(data_dir) == [], do: "ok", else: "error")

  defp collect_errors(data_dir) do
    @known_logs
    |> Enum.flat_map(fn relative_path ->
      path = Path.join(data_dir, relative_path)

      if File.exists?(path) do
        path
        |> File.stream!()
        |> Stream.with_index(1)
        |> Enum.flat_map(fn {line, line_no} ->
          trimmed = String.trim(line)

          cond do
            trimmed == "" or String.starts_with?(trimmed, "#") ->
              []

            true ->
              case Jason.decode(trimmed) do
                {:ok, _} ->
                  []

                {:error, error} ->
                  [%{file: relative_path, line: line_no, error: Exception.message(error)}]
              end
          end
        end)
      else
        []
      end
    end)
  end

  defp count_records(data_dir) do
    Enum.reduce(@known_logs, 0, fn relative_path, count ->
      path = Path.join(data_dir, relative_path)
      if File.exists?(path), do: count + Enum.count(File.stream!(path)), else: count
    end)
  end
end
