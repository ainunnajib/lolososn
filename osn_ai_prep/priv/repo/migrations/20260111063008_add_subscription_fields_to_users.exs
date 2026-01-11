defmodule OsnAiPrep.Repo.Migrations.AddSubscriptionFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # Stripe integration
      add :stripe_customer_id, :string
      add :subscription_status, :string, default: "free"
      add :subscription_plan, :string
      add :subscription_ends_at, :utc_datetime

      # Competition prep mode
      add :prep_mode, :string, default: "noai_prelim"
      add :preferred_language, :string, default: "en"

      # Profile
      add :name, :string
    end

    create index(:users, [:stripe_customer_id])
    create index(:users, [:subscription_status])
  end
end
