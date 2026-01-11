defmodule OsnAiPrep.Repo do
  use Ecto.Repo,
    otp_app: :osn_ai_prep,
    adapter: Ecto.Adapters.Postgres
end
