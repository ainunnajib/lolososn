defmodule OsnAiPrep.Repo.Migrations.AddProblemsIndexes do
  use Ecto.Migration

  def change do
    create index(:problems, [:topic])
    create index(:problems, [:difficulty])
    create index(:problems, [:competition])
  end
end
