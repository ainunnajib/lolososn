defmodule OsnAiPrep.Problems.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  alias OsnAiPrep.Problems.Problem

  schema "submissions" do
    field :solved_at, :utc_datetime
    field :notes, :string

    # These will be replaced with belongs_to when User schema exists
    field :user_id, :id
    belongs_to :problem, Problem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:solved_at, :notes, :user_id, :problem_id])
    |> validate_required([:user_id, :problem_id])
    |> unique_constraint([:user_id, :problem_id])
  end
end
