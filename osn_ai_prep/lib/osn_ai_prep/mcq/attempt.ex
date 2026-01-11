defmodule OsnAiPrep.Mcq.Attempt do
  use Ecto.Schema
  import Ecto.Changeset

  alias OsnAiPrep.Mcq.Question
  alias OsnAiPrep.Accounts.User

  @moduledoc """
  Tracks user attempts at MCQ questions.

  Each attempt records:
  - The user who made the attempt
  - The question attempted
  - The answer selected (A, B, C, or D)
  - Whether it was correct
  - Time taken (in seconds)
  - Session ID for grouping quiz sessions
  """

  schema "mcq_attempts" do
    field :selected_answer, :string
    field :is_correct, :boolean, default: false
    field :time_taken_seconds, :integer
    field :session_id, :string

    belongs_to :user, User
    belongs_to :question, Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attempt, attrs) do
    attempt
    |> cast(attrs, [:selected_answer, :is_correct, :time_taken_seconds, :session_id, :user_id, :question_id])
    |> validate_required([:selected_answer, :user_id, :question_id])
    |> validate_inclusion(:selected_answer, ["A", "B", "C", "D"])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:question_id)
  end

  @doc """
  Creates a changeset for an attempt and automatically determines correctness.
  """
  def create_changeset(attempt, attrs, correct_answer) do
    attrs = Map.put(attrs, "is_correct", attrs["selected_answer"] == correct_answer)

    attempt
    |> changeset(attrs)
  end
end
