defmodule OsnAiPrep.Repo.Migrations.CreateMcqAttempts do
  use Ecto.Migration

  def change do
    create table(:mcq_attempts) do
      add :selected_answer, :string, null: false
      add :is_correct, :boolean, default: false, null: false
      add :time_taken_seconds, :integer
      add :session_id, :string

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :question_id, references(:mcq_questions, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:mcq_attempts, [:user_id])
    create index(:mcq_attempts, [:question_id])
    create index(:mcq_attempts, [:session_id])
    create index(:mcq_attempts, [:user_id, :is_correct])
  end
end
