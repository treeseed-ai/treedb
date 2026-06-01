defmodule TreeDb.Git do
  @moduledoc false

  def inspect_repository(path) do
    case TreeDb.Native.inspect_repository(path) do
      {:ok, json} -> {:ok, Jason.decode!(json)}
      {:error, json} -> {:error, Jason.decode!(json)}
    end
  end
end
