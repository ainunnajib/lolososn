defmodule OsnAiPrep.Repo.Migrations.CreateLearningTables do
  use Ecto.Migration

  def change do
    create table(:lessons) do
      # Bilingual content
      add :title_en, :string, null: false
      add :title_id, :string
      add :description_en, :text
      add :description_id, :text
      add :content_en, :text
      add :content_id, :text

      # Organization
      add :section, :string, null: false
      add :order, :integer, null: false

      # Metadata
      add :difficulty, :string, null: false
      add :estimated_minutes, :integer
      add :topic, :string

      # Resources
      add :video_url, :string
      add :colab_url, :string
      add :external_links, {:array, :map}, default: []

      # Free tier access
      add :is_free, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:section, :order])
    create index(:lessons, [:difficulty])
    create index(:lessons, [:topic])
    create index(:lessons, [:is_free])

    create table(:lesson_progress) do
      add :completed, :boolean, default: false
      add :completed_at, :utc_datetime
      add :time_spent_seconds, :integer, default: 0
      add :quiz_score, :integer
      add :last_accessed_at, :utc_datetime

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :lesson_id, references(:lessons, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:lesson_progress, [:user_id, :lesson_id])
    create index(:lesson_progress, [:user_id])
    create index(:lesson_progress, [:lesson_id])
    create index(:lesson_progress, [:completed])
  end
end
