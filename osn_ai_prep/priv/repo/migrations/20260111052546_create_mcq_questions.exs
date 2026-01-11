defmodule OsnAiPrep.Repo.Migrations.CreateMcqQuestions do
  use Ecto.Migration

  def change do
    create table(:mcq_questions) do
      add :question_en, :text
      add :question_id, :text
      add :option_a_en, :string
      add :option_a_id, :string
      add :option_b_en, :string
      add :option_b_id, :string
      add :option_c_en, :string
      add :option_c_id, :string
      add :option_d_en, :string
      add :option_d_id, :string
      add :correct_answer, :string
      add :explanation_en, :text
      add :explanation_id, :text
      add :topic, :string
      add :difficulty, :string
      add :competition, :string

      timestamps(type: :utc_datetime)
    end

    create index(:mcq_questions, [:topic])
    create index(:mcq_questions, [:difficulty])
    create index(:mcq_questions, [:competition])
  end
end
