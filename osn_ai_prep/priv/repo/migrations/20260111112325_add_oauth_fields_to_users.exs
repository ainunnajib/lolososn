defmodule OsnAiPrep.Repo.Migrations.AddOauthFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :provider, :string
      add :provider_uid, :string
    end

    # Index for OAuth lookups
    create index(:users, [:provider, :provider_uid])
  end
end
