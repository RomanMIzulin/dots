defmodule ElixirBack.Repo do
  use Ecto.Repo,
    otp_app: :elixir_back,
    adapter: Ecto.Adapters.SQLite3
end
