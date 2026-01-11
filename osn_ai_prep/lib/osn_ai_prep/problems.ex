defmodule OsnAiPrep.Problems do
  @moduledoc """
  The Problems context.
  """

  import Ecto.Query, warn: false
  alias OsnAiPrep.Repo

  alias OsnAiPrep.Problems.Problem

  @doc """
  Returns the list of problems.

  ## Examples

      iex> list_problems()
      [%Problem{}, ...]

  """
  def list_problems do
    Repo.all(Problem)
  end

  @doc """
  Returns the list of problems filtered by given criteria.

  ## Examples

      iex> list_problems_with_filters(%{topic: "ml_basics", difficulty: "easy"})
      [%Problem{}, ...]

  """
  def list_problems_with_filters(filters) when is_map(filters) do
    Problem
    |> filter_by_topic(filters[:topic] || filters["topic"])
    |> filter_by_difficulty(filters[:difficulty] || filters["difficulty"])
    |> filter_by_competition(filters[:competition] || filters["competition"])
    |> Repo.all()
  end

  defp filter_by_topic(query, nil), do: query
  defp filter_by_topic(query, ""), do: query
  defp filter_by_topic(query, topic), do: from(p in query, where: p.topic == ^topic)

  defp filter_by_difficulty(query, nil), do: query
  defp filter_by_difficulty(query, ""), do: query
  defp filter_by_difficulty(query, difficulty), do: from(p in query, where: p.difficulty == ^difficulty)

  defp filter_by_competition(query, nil), do: query
  defp filter_by_competition(query, ""), do: query
  defp filter_by_competition(query, competition), do: from(p in query, where: p.competition == ^competition)

  @doc """
  Gets a single problem.

  Raises `Ecto.NoResultsError` if the Problem does not exist.

  ## Examples

      iex> get_problem!(123)
      %Problem{}

      iex> get_problem!(456)
      ** (Ecto.NoResultsError)

  """
  def get_problem!(id), do: Repo.get!(Problem, id)

  @doc """
  Creates a problem.

  ## Examples

      iex> create_problem(%{field: value})
      {:ok, %Problem{}}

      iex> create_problem(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_problem(attrs) do
    %Problem{}
    |> Problem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a problem.

  ## Examples

      iex> update_problem(problem, %{field: new_value})
      {:ok, %Problem{}}

      iex> update_problem(problem, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_problem(%Problem{} = problem, attrs) do
    problem
    |> Problem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a problem.

  ## Examples

      iex> delete_problem(problem)
      {:ok, %Problem{}}

      iex> delete_problem(problem)
      {:error, %Ecto.Changeset{}}

  """
  def delete_problem(%Problem{} = problem) do
    Repo.delete(problem)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking problem changes.

  ## Examples

      iex> change_problem(problem)
      %Ecto.Changeset{data: %Problem{}}

  """
  def change_problem(%Problem{} = problem, attrs \\ %{}) do
    Problem.changeset(problem, attrs)
  end

  alias OsnAiPrep.Problems.Submission

  @doc """
  Returns the list of submissions.

  ## Examples

      iex> list_submissions()
      [%Submission{}, ...]

  """
  def list_submissions do
    Repo.all(Submission)
  end

  @doc """
  Gets a single submission.

  Raises `Ecto.NoResultsError` if the Submission does not exist.

  ## Examples

      iex> get_submission!(123)
      %Submission{}

      iex> get_submission!(456)
      ** (Ecto.NoResultsError)

  """
  def get_submission!(id), do: Repo.get!(Submission, id)

  @doc """
  Creates a submission.

  ## Examples

      iex> create_submission(%{field: value})
      {:ok, %Submission{}}

      iex> create_submission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_submission(attrs) do
    %Submission{}
    |> Submission.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a submission.

  ## Examples

      iex> update_submission(submission, %{field: new_value})
      {:ok, %Submission{}}

      iex> update_submission(submission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_submission(%Submission{} = submission, attrs) do
    submission
    |> Submission.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a submission.

  ## Examples

      iex> delete_submission(submission)
      {:ok, %Submission{}}

      iex> delete_submission(submission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_submission(%Submission{} = submission) do
    Repo.delete(submission)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking submission changes.

  ## Examples

      iex> change_submission(submission)
      %Ecto.Changeset{data: %Submission{}}

  """
  def change_submission(%Submission{} = submission, attrs \\ %{}) do
    Submission.changeset(submission, attrs)
  end

  # Dashboard & Leaderboard functions

  @doc """
  Returns the count of problems solved by a user.
  """
  def count_user_submissions(user_id) do
    from(s in Submission, where: s.user_id == ^user_id, select: count(s.id))
    |> Repo.one()
  end

  @doc """
  Returns submissions for a user with preloaded problems.
  """
  def list_user_submissions(user_id) do
    from(s in Submission,
      where: s.user_id == ^user_id,
      preload: [:problem],
      order_by: [desc: s.solved_at]
    )
    |> Repo.all()
  end

  @doc """
  Returns recent submissions for a user (last N).
  """
  def list_recent_user_submissions(user_id, limit \\ 5) do
    from(s in Submission,
      where: s.user_id == ^user_id,
      preload: [:problem],
      order_by: [desc: s.solved_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Returns user's progress by topic.
  Returns a map of %{topic => %{solved: count, total: count}}
  """
  def get_user_progress_by_topic(user_id) do
    # Get all problems grouped by topic
    all_problems =
      from(p in Problem, group_by: p.topic, select: {p.topic, count(p.id)})
      |> Repo.all()
      |> Map.new()

    # Get solved problems by topic for this user
    solved_problems =
      from(s in Submission,
        join: p in Problem, on: s.problem_id == p.id,
        where: s.user_id == ^user_id,
        group_by: p.topic,
        select: {p.topic, count(s.id)}
      )
      |> Repo.all()
      |> Map.new()

    # Combine into progress map
    all_problems
    |> Enum.map(fn {topic, total} ->
      solved = Map.get(solved_problems, topic, 0)
      {topic, %{solved: solved, total: total, percentage: safe_percentage(solved, total)}}
    end)
    |> Map.new()
  end

  @doc """
  Returns user's progress by difficulty.
  """
  def get_user_progress_by_difficulty(user_id) do
    all_problems =
      from(p in Problem, group_by: p.difficulty, select: {p.difficulty, count(p.id)})
      |> Repo.all()
      |> Map.new()

    solved_problems =
      from(s in Submission,
        join: p in Problem, on: s.problem_id == p.id,
        where: s.user_id == ^user_id,
        group_by: p.difficulty,
        select: {p.difficulty, count(s.id)}
      )
      |> Repo.all()
      |> Map.new()

    all_problems
    |> Enum.map(fn {difficulty, total} ->
      solved = Map.get(solved_problems, difficulty, 0)
      {difficulty, %{solved: solved, total: total, percentage: safe_percentage(solved, total)}}
    end)
    |> Map.new()
  end

  @doc """
  Returns leaderboard data - top users by problems solved.
  """
  def get_leaderboard(limit \\ 100) do
    from(s in Submission,
      join: u in assoc(s, :user),
      group_by: [u.id, u.email],
      select: %{
        user_id: u.id,
        email: u.email,
        problems_solved: count(s.id),
        last_solved_at: max(s.solved_at)
      },
      order_by: [desc: count(s.id), asc: max(s.solved_at)],
      limit: ^limit
    )
    |> Repo.all()
    |> Enum.with_index(1)
    |> Enum.map(fn {user, rank} -> Map.put(user, :rank, rank) end)
  end

  @doc """
  Returns a user's rank on the leaderboard.
  """
  def get_user_rank(user_id) do
    leaderboard = get_leaderboard(1000)
    Enum.find(leaderboard, fn entry -> entry.user_id == user_id end)
  end

  @doc """
  Returns the total count of problems.
  """
  def count_problems do
    Repo.aggregate(Problem, :count, :id)
  end

  @doc """
  Check if a user has solved a specific problem.
  """
  def user_solved_problem?(user_id, problem_id) do
    from(s in Submission, where: s.user_id == ^user_id and s.problem_id == ^problem_id)
    |> Repo.exists?()
  end

  @doc """
  Mark a problem as solved by a user.
  """
  def mark_problem_solved(user_id, problem_id, notes \\ nil) do
    attrs = %{
      user_id: user_id,
      problem_id: problem_id,
      solved_at: DateTime.utc_now(),
      notes: notes
    }

    case user_solved_problem?(user_id, problem_id) do
      true -> {:error, :already_solved}
      false -> create_submission(attrs)
    end
  end

  defp safe_percentage(_solved, 0), do: 0
  defp safe_percentage(solved, total), do: round(solved / total * 100)
end
