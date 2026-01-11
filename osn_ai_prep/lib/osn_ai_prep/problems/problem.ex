defmodule OsnAiPrep.Problems.Problem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "problems" do
    field :title_en, :string
    field :title_id, :string
    field :description_en, :string
    field :description_id, :string
    field :difficulty, :string
    field :topic, :string
    field :colab_url, :string
    field :competition, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(problem, attrs) do
    problem
    |> cast(attrs, [:title_en, :title_id, :description_en, :description_id, :difficulty, :topic, :colab_url, :competition])
    |> validate_required([:title_en, :title_id, :description_en, :description_id, :difficulty, :topic, :colab_url, :competition])
  end
end
