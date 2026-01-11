defmodule OsnAiPrep.Repo.Migrations.CreateProblems do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :title_en, :string
      add :title_id, :string
      add :description_en, :text
      add :description_id, :text
      add :difficulty, :string
      add :topic, :string
      add :colab_url, :string
      add :competition, :string

      timestamps(type: :utc_datetime)
    end
  end
end
