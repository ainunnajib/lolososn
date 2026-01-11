defmodule OsnAiPrep.Problems.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  alias OsnAiPrep.Problems.Problem
  alias OsnAiPrep.Accounts.User

  schema "submissions" do
    field :solved_at, :utc_datetime
    field :notes, :string

    belongs_to :user, User
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
