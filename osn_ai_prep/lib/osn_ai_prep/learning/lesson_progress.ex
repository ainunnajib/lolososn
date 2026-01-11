defmodule OsnAiPrep.Learning.LessonProgress do
  use Ecto.Schema
  import Ecto.Changeset

  alias OsnAiPrep.Learning.Lesson
  alias OsnAiPrep.Accounts.User

  @moduledoc """
  Tracks user progress through lessons.

  Records:
  - Completion status
  - Time spent on the lesson
  - Quiz scores (if applicable)
  - Last accessed timestamp
  """

  schema "lesson_progress" do
    field :completed, :boolean, default: false
    field :completed_at, :utc_datetime
    field :time_spent_seconds, :integer, default: 0
    field :quiz_score, :integer  # Percentage 0-100
    field :last_accessed_at, :utc_datetime

    belongs_to :user, User
    belongs_to :lesson, Lesson

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(progress, attrs) do
    progress
    |> cast(attrs, [:completed, :completed_at, :time_spent_seconds, :quiz_score, :last_accessed_at, :user_id, :lesson_id])
    |> validate_required([:user_id, :lesson_id])
    |> validate_number(:quiz_score, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> unique_constraint([:user_id, :lesson_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:lesson_id)
  end

  @doc """
  Changeset for marking a lesson as completed.
  """
  def complete_changeset(progress, attrs \\ %{}) do
    progress
    |> changeset(attrs)
    |> put_change(:completed, true)
    |> put_change(:completed_at, DateTime.utc_now(:second))
  end

  @doc """
  Changeset for updating time spent.
  """
  def update_time_changeset(progress, additional_seconds) do
    current_time = progress.time_spent_seconds || 0

    progress
    |> change(time_spent_seconds: current_time + additional_seconds)
    |> put_change(:last_accessed_at, DateTime.utc_now(:second))
  end
end
