defmodule OsnAiPrep.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :solved_at, :utc_datetime
      add :notes, :text
      add :user_id, references(:users, on_delete: :delete_all)
      add :problem_id, references(:problems, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:submissions, [:user_id])
    create index(:submissions, [:problem_id])
    create unique_index(:submissions, [:user_id, :problem_id])
  end
end
