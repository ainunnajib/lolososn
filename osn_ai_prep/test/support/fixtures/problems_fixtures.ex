defmodule OsnAiPrep.ProblemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OsnAiPrep.Problems` context.
  """

  @doc """
  Generate a problem.
  """
  def problem_fixture(attrs \\ %{}) do
    {:ok, problem} =
      attrs
      |> Enum.into(%{
        colab_url: "https://colab.research.google.com/example",
        competition: "ioai",
        description_en: "Implement a neural network classifier",
        description_id: "Implementasikan classifier neural network",
        difficulty: "medium",
        title_en: "Neural Network Classification",
        title_id: "Klasifikasi Neural Network",
        topic: "neural_networks"
      })
      |> OsnAiPrep.Problems.create_problem()

    problem
  end

  @doc """
  Generate a submission.
  """
  def submission_fixture(attrs \\ %{}) do
    # Create a problem and user if not provided
    problem = attrs[:problem] || problem_fixture()
    user = attrs[:user] || OsnAiPrep.AccountsFixtures.user_fixture()

    {:ok, submission} =
      attrs
      |> Enum.into(%{
        notes: "Solved using backpropagation",
        solved_at: ~U[2026-01-10 05:25:00Z],
        user_id: user.id,
        problem_id: problem.id
      })
      |> OsnAiPrep.Problems.create_submission()

    submission
  end
end
