defmodule OsnAiPrep.Learning do
  @moduledoc """
  The Learning context handles lessons and user progress.

  Provides functions for:
  - Listing and filtering lessons by section, difficulty, topic
  - Tracking user progress through lessons
  - Managing lesson completion and quiz scores
  """

  import Ecto.Query, warn: false
  alias OsnAiPrep.Repo
  alias OsnAiPrep.Learning.{Lesson, LessonProgress}

  # ============================================================================
  # Lessons
  # ============================================================================

  @doc """
  Lists all lessons, optionally filtered by criteria.

  ## Options
    * `:section` - Filter by section (e.g., "python_basics")
    * `:difficulty` - Filter by difficulty ("beginner", "intermediate", "advanced")
    * `:topic` - Filter by topic
    * `:free_only` - If true, only return free lessons
  """
  def list_lessons(opts \\ []) do
    Lesson
    |> apply_lesson_filters(opts)
    |> order_by([l], [l.section, l.order])
    |> Repo.all()
  end

  defp apply_lesson_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:section, section}, q when is_binary(section) ->
        where(q, [l], l.section == ^section)

      {:difficulty, difficulty}, q when is_binary(difficulty) ->
        where(q, [l], l.difficulty == ^difficulty)

      {:topic, topic}, q when is_binary(topic) ->
        where(q, [l], l.topic == ^topic)

      {:free_only, true}, q ->
        where(q, [l], l.is_free == true)

      _, q ->
        q
    end)
  end

  @doc """
  Gets a single lesson by ID.

  Raises `Ecto.NoResultsError` if the Lesson does not exist.
  """
  def get_lesson!(id), do: Repo.get!(Lesson, id)

  @doc """
  Gets a lesson by section and order.
  """
  def get_lesson_by_position(section, order) do
    Repo.get_by(Lesson, section: section, order: order)
  end

  @doc """
  Returns the next lesson in the sequence.
  """
  def get_next_lesson(%Lesson{section: section, order: order}) do
    # First try next in same section
    case Repo.get_by(Lesson, section: section, order: order + 1) do
      nil ->
        # Try first lesson of next section
        get_first_lesson_of_next_section(section)

      lesson ->
        lesson
    end
  end

  defp get_first_lesson_of_next_section(current_section) do
    sections = [
      "python_basics",
      "ml_fundamentals",
      "neural_networks",
      "deep_learning",
      "computer_vision",
      "nlp",
      "advanced_topics"
    ]

    current_index = Enum.find_index(sections, &(&1 == current_section))

    if current_index && current_index < length(sections) - 1 do
      next_section = Enum.at(sections, current_index + 1)
      Repo.get_by(Lesson, section: next_section, order: 1)
    else
      nil
    end
  end

  @doc """
  Gets lessons grouped by section with counts.
  """
  def get_lessons_by_section do
    Lesson
    |> group_by([l], l.section)
    |> select([l], {l.section, count(l.id)})
    |> Repo.all()
    |> Map.new()
  end

  @doc """
  Creates a new lesson.
  """
  def create_lesson(attrs \\ %{}) do
    %Lesson{}
    |> Lesson.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lesson.
  """
  def update_lesson(%Lesson{} = lesson, attrs) do
    lesson
    |> Lesson.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lesson.
  """
  def delete_lesson(%Lesson{} = lesson) do
    Repo.delete(lesson)
  end

  # ============================================================================
  # Lesson Progress
  # ============================================================================

  @doc """
  Gets or creates progress record for a user and lesson.
  """
  def get_or_create_progress(user_id, lesson_id) do
    case Repo.get_by(LessonProgress, user_id: user_id, lesson_id: lesson_id) do
      nil ->
        %LessonProgress{}
        |> LessonProgress.changeset(%{user_id: user_id, lesson_id: lesson_id})
        |> Repo.insert()

      progress ->
        {:ok, progress}
    end
  end

  @doc """
  Gets all progress records for a user.
  """
  def list_user_progress(user_id) do
    LessonProgress
    |> where([p], p.user_id == ^user_id)
    |> preload(:lesson)
    |> Repo.all()
  end

  @doc """
  Gets progress for a specific lesson.
  """
  def get_progress(user_id, lesson_id) do
    Repo.get_by(LessonProgress, user_id: user_id, lesson_id: lesson_id)
  end

  @doc """
  Marks a lesson as completed for a user.
  """
  def complete_lesson(user_id, lesson_id, attrs \\ %{}) do
    case get_or_create_progress(user_id, lesson_id) do
      {:ok, progress} ->
        progress
        |> LessonProgress.complete_changeset(attrs)
        |> Repo.update()

      error ->
        error
    end
  end

  @doc """
  Updates time spent on a lesson.
  """
  def update_time_spent(user_id, lesson_id, additional_seconds) do
    case get_or_create_progress(user_id, lesson_id) do
      {:ok, progress} ->
        progress
        |> LessonProgress.update_time_changeset(additional_seconds)
        |> Repo.update()

      error ->
        error
    end
  end

  @doc """
  Records a quiz score for a lesson.
  """
  def record_quiz_score(user_id, lesson_id, score) when score >= 0 and score <= 100 do
    case get_or_create_progress(user_id, lesson_id) do
      {:ok, progress} ->
        progress
        |> LessonProgress.changeset(%{quiz_score: score})
        |> Repo.update()

      error ->
        error
    end
  end

  @doc """
  Gets completion stats for a user.

  Returns a map with:
  - :total_lessons - Total number of lessons
  - :completed_lessons - Number of completed lessons
  - :total_time_seconds - Total time spent across all lessons
  - :average_quiz_score - Average quiz score (or nil if no quizzes taken)
  - :section_progress - Map of section -> {completed, total}
  """
  def get_user_stats(user_id) do
    total_lessons = Repo.aggregate(Lesson, :count)

    progress_query =
      LessonProgress
      |> where([p], p.user_id == ^user_id)

    completed_lessons =
      progress_query
      |> where([p], p.completed == true)
      |> Repo.aggregate(:count)

    total_time =
      progress_query
      |> Repo.aggregate(:sum, :time_spent_seconds) || 0

    avg_score =
      progress_query
      |> where([p], not is_nil(p.quiz_score))
      |> Repo.aggregate(:avg, :quiz_score)

    section_progress = calculate_section_progress(user_id)

    %{
      total_lessons: total_lessons,
      completed_lessons: completed_lessons,
      total_time_seconds: total_time,
      average_quiz_score: avg_score && round(avg_score),
      section_progress: section_progress,
      completion_percentage:
        if(total_lessons > 0, do: round(completed_lessons / total_lessons * 100), else: 0)
    }
  end

  defp calculate_section_progress(user_id) do
    # Get total lessons per section
    section_totals =
      Lesson
      |> group_by([l], l.section)
      |> select([l], {l.section, count(l.id)})
      |> Repo.all()
      |> Map.new()

    # Get completed lessons per section
    section_completed =
      LessonProgress
      |> join(:inner, [p], l in Lesson, on: p.lesson_id == l.id)
      |> where([p], p.user_id == ^user_id and p.completed == true)
      |> group_by([p, l], l.section)
      |> select([p, l], {l.section, count(p.id)})
      |> Repo.all()
      |> Map.new()

    # Combine into progress map
    for {section, total} <- section_totals, into: %{} do
      completed = Map.get(section_completed, section, 0)
      {section, %{completed: completed, total: total}}
    end
  end

  # ============================================================================
  # Free Tier Helpers
  # ============================================================================

  @free_lesson_limit 3

  @doc """
  Checks if a user can access a lesson based on subscription status.
  """
  def can_access_lesson?(_user, %Lesson{is_free: true}), do: true

  def can_access_lesson?(%{subscription_status: "active"}, _lesson), do: true

  def can_access_lesson?(_user, lesson) do
    # Free users can access the first N lessons of each section
    lesson.order <= @free_lesson_limit
  end

  @doc """
  Returns all lessons a user can access.
  """
  def list_accessible_lessons(user) do
    lessons = list_lessons()

    Enum.filter(lessons, fn lesson ->
      can_access_lesson?(user, lesson)
    end)
  end
end
