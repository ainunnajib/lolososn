defmodule OsnAiPrep.Subscriptions.Paywall do
  @moduledoc """
  Paywall logic for controlling access to premium content.

  Free tier limits:
  - 3 intro lessons per section
  - 5 starter problems
  - 30 MCQ questions
  - 1 mini mock exam (30 min)
  """

  alias OsnAiPrep.Accounts.User

  # Free tier content limits
  @free_lesson_ids [1, 2, 3]
  @free_problem_ids [1, 2, 3, 4, 5]
  @free_mcq_limit 30
  @free_mock_exam_limit 1

  @doc """
  Checks if a user can access a specific lesson.
  """
  def can_access_lesson?(%User{} = user, lesson_id) do
    has_premium?(user) or lesson_id in @free_lesson_ids
  end

  def can_access_lesson?(nil, lesson_id) do
    lesson_id in @free_lesson_ids
  end

  @doc """
  Checks if a user can access a specific problem.
  """
  def can_access_problem?(%User{} = user, problem_id) do
    has_premium?(user) or problem_id in @free_problem_ids
  end

  def can_access_problem?(nil, problem_id) do
    problem_id in @free_problem_ids
  end

  @doc """
  Checks if a user can access MCQ practice.
  Returns :unlimited for premium users, or remaining count for free users.
  """
  def mcq_access(user, attempts_count \\ 0)

  def mcq_access(%User{} = user, attempts_count) do
    if has_premium?(user) do
      :unlimited
    else
      remaining = max(0, @free_mcq_limit - attempts_count)
      {:limited, remaining}
    end
  end

  def mcq_access(nil, attempts_count) do
    remaining = max(0, @free_mcq_limit - attempts_count)
    {:limited, remaining}
  end

  @doc """
  Checks if a user can take a mock exam.
  """
  def can_take_mock_exam?(user, exams_taken \\ 0)

  def can_take_mock_exam?(%User{} = user, exams_taken) do
    has_premium?(user) or exams_taken < @free_mock_exam_limit
  end

  def can_take_mock_exam?(nil, exams_taken) do
    exams_taken < @free_mock_exam_limit
  end

  @doc """
  Checks if a user can use AI hints.
  """
  def can_use_ai_hints?(%User{} = user) do
    has_premium?(user)
  end

  def can_use_ai_hints?(nil), do: false

  @doc """
  Checks if a user can participate in the leaderboard.
  """
  def can_participate_in_leaderboard?(%User{} = user) do
    has_premium?(user)
  end

  def can_participate_in_leaderboard?(nil), do: false

  @doc """
  Checks if a user can get a completion certificate.
  """
  def can_get_certificate?(%User{} = user) do
    has_premium?(user)
  end

  def can_get_certificate?(nil), do: false

  @doc """
  Checks if user has premium (active subscription).
  """
  def has_premium?(%User{subscription_status: "active"}), do: true
  def has_premium?(_), do: false

  @doc """
  Gets the list of free lesson IDs.
  """
  def free_lesson_ids, do: @free_lesson_ids

  @doc """
  Gets the list of free problem IDs.
  """
  def free_problem_ids, do: @free_problem_ids

  @doc """
  Gets the free MCQ limit.
  """
  def free_mcq_limit, do: @free_mcq_limit

  @doc """
  Returns a summary of what features are available for a user.
  """
  def feature_access(%User{} = user) do
    %{
      lessons: if(has_premium?(user), do: :all, else: {:limited, @free_lesson_ids}),
      problems: if(has_premium?(user), do: :all, else: {:limited, @free_problem_ids}),
      mcq: if(has_premium?(user), do: :unlimited, else: {:limited, @free_mcq_limit}),
      mock_exams: if(has_premium?(user), do: :unlimited, else: {:limited, @free_mock_exam_limit}),
      ai_hints: has_premium?(user),
      leaderboard: has_premium?(user),
      certificate: has_premium?(user)
    }
  end

  def feature_access(nil) do
    %{
      lessons: {:limited, @free_lesson_ids},
      problems: {:limited, @free_problem_ids},
      mcq: {:limited, @free_mcq_limit},
      mock_exams: {:limited, @free_mock_exam_limit},
      ai_hints: false,
      leaderboard: false,
      certificate: false
    }
  end

  @doc """
  Returns upgrade messaging for blocked features.
  """
  def upgrade_message(:lesson) do
    "Unlock all lessons with a premium subscription"
  end

  def upgrade_message(:problem) do
    "Unlock #{50 - length(@free_problem_ids)} more problems with premium"
  end

  def upgrade_message(:mcq) do
    "Unlock 500+ MCQ questions with premium"
  end

  def upgrade_message(:mock_exam) do
    "Unlock full mock exams (3+ hours) with premium"
  end

  def upgrade_message(:ai_hints) do
    "Get unlimited AI hints with premium"
  end

  def upgrade_message(_) do
    "Upgrade to premium for full access"
  end
end
