defmodule OsnAiPrep.Mcq do
  @moduledoc """
  The Mcq context for managing MCQ questions and tracking user attempts.
  """

  import Ecto.Query, warn: false
  alias OsnAiPrep.Repo

  alias OsnAiPrep.Mcq.Question
  alias OsnAiPrep.Mcq.Attempt

  @doc """
  Returns the list of mcq_questions.

  ## Examples

      iex> list_mcq_questions()
      [%Question{}, ...]

  """
  def list_mcq_questions do
    Repo.all(Question)
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id), do: Repo.get!(Question, id)

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{data: %Question{}}

  """
  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  @doc """
  Lists questions filtered by topic.
  """
  def list_questions_by_topic(topic) do
    Question
    |> where([q], q.topic == ^topic)
    |> Repo.all()
  end

  @doc """
  Lists questions filtered by difficulty.
  """
  def list_questions_by_difficulty(difficulty) do
    Question
    |> where([q], q.difficulty == ^difficulty)
    |> Repo.all()
  end

  @doc """
  Lists questions with filters.
  """
  def list_questions(filters \\ %{}) do
    Question
    |> apply_filters(filters)
    |> Repo.all()
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:topic, topic}, query when is_binary(topic) and topic != "" ->
        where(query, [q], q.topic == ^topic)

      {:difficulty, difficulty}, query when is_binary(difficulty) and difficulty != "" ->
        where(query, [q], q.difficulty == ^difficulty)

      {:competition, competition}, query when is_binary(competition) and competition != "" ->
        where(query, [q], q.competition == ^competition)

      {:limit, limit}, query when is_integer(limit) ->
        limit(query, ^limit)

      _, query ->
        query
    end)
  end

  @doc """
  Gets random questions for a quiz session.
  """
  def get_random_questions(count, filters \\ %{}) do
    Question
    |> apply_filters(filters)
    |> order_by(fragment("RANDOM()"))
    |> limit(^count)
    |> Repo.all()
  end

  @doc """
  Returns a list of unique topics from all questions.
  """
  def list_topics do
    Question
    |> select([q], q.topic)
    |> distinct(true)
    |> order_by([q], q.topic)
    |> Repo.all()
  end

  @doc """
  Counts total questions.
  """
  def count_questions(filters \\ %{}) do
    Question
    |> apply_filters(filters)
    |> Repo.aggregate(:count)
  end

  # ============================================
  # Attempt Functions
  # ============================================

  @doc """
  Creates an attempt record.
  """
  def create_attempt(attrs) do
    %Attempt{}
    |> Attempt.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates an attempt with automatic correctness check.
  """
  def submit_answer(user_id, question_id, selected_answer, session_id \\ nil, time_taken \\ nil) do
    question = get_question!(question_id)
    is_correct = selected_answer == question.correct_answer

    attrs = %{
      user_id: user_id,
      question_id: question_id,
      selected_answer: selected_answer,
      is_correct: is_correct,
      session_id: session_id,
      time_taken_seconds: time_taken
    }

    case create_attempt(attrs) do
      {:ok, attempt} -> {:ok, %{attempt | question: question}}
      error -> error
    end
  end

  @doc """
  Counts total attempts by a user.
  """
  def count_user_attempts(user_id) do
    Attempt
    |> where([a], a.user_id == ^user_id)
    |> Repo.aggregate(:count)
  end

  @doc """
  Counts correct attempts by a user.
  """
  def count_user_correct_attempts(user_id) do
    Attempt
    |> where([a], a.user_id == ^user_id and a.is_correct == true)
    |> Repo.aggregate(:count)
  end

  @doc """
  Gets user stats for MCQ practice.
  """
  def get_user_stats(user_id) do
    total = count_user_attempts(user_id)
    correct = count_user_correct_attempts(user_id)

    %{
      total_attempts: total,
      correct_attempts: correct,
      accuracy: if(total > 0, do: round(correct / total * 100), else: 0)
    }
  end

  @doc """
  Gets user stats by topic.
  """
  def get_user_stats_by_topic(user_id) do
    Attempt
    |> join(:inner, [a], q in Question, on: a.question_id == q.id)
    |> where([a], a.user_id == ^user_id)
    |> group_by([a, q], q.topic)
    |> select([a, q], {
      q.topic,
      count(a.id),
      sum(fragment("CASE WHEN ? THEN 1 ELSE 0 END", a.is_correct))
    })
    |> Repo.all()
    |> Enum.map(fn {topic, total, correct} ->
      correct = correct || 0
      {topic, %{total: total, correct: correct, accuracy: if(total > 0, do: round(correct / total * 100), else: 0)}}
    end)
    |> Map.new()
  end

  @doc """
  Gets recent attempts by a user.
  """
  def list_recent_attempts(user_id, limit \\ 10) do
    Attempt
    |> where([a], a.user_id == ^user_id)
    |> order_by([a], desc: a.inserted_at)
    |> limit(^limit)
    |> preload(:question)
    |> Repo.all()
  end

  @doc """
  Gets attempts for a specific session.
  """
  def list_session_attempts(session_id) do
    Attempt
    |> where([a], a.session_id == ^session_id)
    |> order_by([a], asc: a.inserted_at)
    |> preload(:question)
    |> Repo.all()
  end

  @doc """
  Generates a unique session ID for a quiz session.
  """
  def generate_session_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end
end
