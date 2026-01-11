defmodule OsnAiPrep.Mcq.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mcq_questions" do
    field :question_en, :string
    field :question_id, :string
    field :option_a_en, :string
    field :option_a_id, :string
    field :option_b_en, :string
    field :option_b_id, :string
    field :option_c_en, :string
    field :option_c_id, :string
    field :option_d_en, :string
    field :option_d_id, :string
    field :correct_answer, :string
    field :explanation_en, :string
    field :explanation_id, :string
    field :topic, :string
    field :difficulty, :string
    field :competition, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [
      :question_en,
      :question_id,
      :option_a_en,
      :option_a_id,
      :option_b_en,
      :option_b_id,
      :option_c_en,
      :option_c_id,
      :option_d_en,
      :option_d_id,
      :correct_answer,
      :explanation_en,
      :explanation_id,
      :topic,
      :difficulty,
      :competition
    ])
    |> validate_required([
      :question_en,
      :option_a_en,
      :option_b_en,
      :option_c_en,
      :option_d_en,
      :correct_answer,
      :topic,
      :difficulty
    ])
    |> validate_inclusion(:correct_answer, ["A", "B", "C", "D"])
    |> validate_inclusion(:difficulty, ["easy", "medium", "hard"])
  end
end
