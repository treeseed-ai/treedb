defmodule TreeDb.Auth.Jwt do
  @moduledoc false

  def validate_config, do: TreeDb.Auth.Verifiers.Hs256Dev.validate_config()
  def verify(token), do: TreeDb.Auth.Verifiers.Hs256Dev.verify(token)
  def verifier_info, do: TreeDb.Auth.Verifiers.Hs256Dev.info()
end
