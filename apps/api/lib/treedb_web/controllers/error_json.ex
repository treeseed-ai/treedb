defmodule TreeDbWeb.ErrorJSON do
  def render(_template, _assigns) do
    %{ok: false, error: %{code: "internal_error", message: "Internal error.", details: %{}}}
  end
end
