defmodule OsnAiPrep.ProblemsTest do
  use OsnAiPrep.DataCase

  alias OsnAiPrep.Problems

  describe "problems" do
    alias OsnAiPrep.Problems.Problem

    import OsnAiPrep.ProblemsFixtures

    @invalid_attrs %{title_en: nil, title_id: nil, description_en: nil, description_id: nil, difficulty: nil, topic: nil, colab_url: nil, competition: nil}

    test "list_problems/0 returns all problems" do
      problem = problem_fixture()
      assert Problems.list_problems() == [problem]
    end

    test "get_problem!/1 returns the problem with given id" do
      problem = problem_fixture()
      assert Problems.get_problem!(problem.id) == problem
    end

    test "create_problem/1 with valid data creates a problem" do
      valid_attrs = %{
        title_en: "Test Problem",
        title_id: "Soal Test",
        description_en: "Solve this problem",
        description_id: "Selesaikan soal ini",
        difficulty: "easy",
        topic: "ml_basics",
        colab_url: "https://colab.research.google.com/test",
        competition: "noai_prelim"
      }

      assert {:ok, %Problem{} = problem} = Problems.create_problem(valid_attrs)
      assert problem.title_en == "Test Problem"
      assert problem.title_id == "Soal Test"
      assert problem.description_en == "Solve this problem"
      assert problem.description_id == "Selesaikan soal ini"
      assert problem.difficulty == "easy"
      assert problem.topic == "ml_basics"
      assert problem.colab_url == "https://colab.research.google.com/test"
      assert problem.competition == "noai_prelim"
    end

    test "create_problem/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Problems.create_problem(@invalid_attrs)
    end

    test "update_problem/2 with valid data updates the problem" do
      problem = problem_fixture()
      update_attrs = %{
        title_en: "Updated Problem",
        difficulty: "hard"
      }

      assert {:ok, %Problem{} = problem} = Problems.update_problem(problem, update_attrs)
      assert problem.title_en == "Updated Problem"
      assert problem.difficulty == "hard"
    end

    test "update_problem/2 with invalid data returns error changeset" do
      problem = problem_fixture()
      assert {:error, %Ecto.Changeset{}} = Problems.update_problem(problem, @invalid_attrs)
      assert problem == Problems.get_problem!(problem.id)
    end

    test "delete_problem/1 deletes the problem" do
      problem = problem_fixture()
      assert {:ok, %Problem{}} = Problems.delete_problem(problem)
      assert_raise Ecto.NoResultsError, fn -> Problems.get_problem!(problem.id) end
    end

    test "change_problem/1 returns a problem changeset" do
      problem = problem_fixture()
      assert %Ecto.Changeset{} = Problems.change_problem(problem)
    end
  end

  describe "submissions" do
    alias OsnAiPrep.Problems.Submission

    import OsnAiPrep.ProblemsFixtures

    @invalid_attrs %{user_id: nil, problem_id: nil}

    test "list_submissions/0 returns all submissions" do
      submission = submission_fixture()
      assert Problems.list_submissions() == [submission]
    end

    test "get_submission!/1 returns the submission with given id" do
      submission = submission_fixture()
      assert Problems.get_submission!(submission.id) == submission
    end

    test "create_submission/1 with valid data creates a submission" do
      problem = problem_fixture()
      user = OsnAiPrep.AccountsFixtures.user_fixture()

      valid_attrs = %{
        solved_at: ~U[2026-01-10 05:25:00Z],
        notes: "Completed successfully",
        user_id: user.id,
        problem_id: problem.id
      }

      assert {:ok, %Submission{} = submission} = Problems.create_submission(valid_attrs)
      assert submission.solved_at == ~U[2026-01-10 05:25:00Z]
      assert submission.notes == "Completed successfully"
      assert submission.user_id == user.id
      assert submission.problem_id == problem.id
    end

    test "create_submission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Problems.create_submission(@invalid_attrs)
    end

    test "update_submission/2 with valid data updates the submission" do
      submission = submission_fixture()
      update_attrs = %{
        solved_at: ~U[2026-01-11 05:25:00Z],
        notes: "Updated notes"
      }

      assert {:ok, %Submission{} = submission} = Problems.update_submission(submission, update_attrs)
      assert submission.solved_at == ~U[2026-01-11 05:25:00Z]
      assert submission.notes == "Updated notes"
    end

    test "update_submission/2 with invalid data returns error changeset" do
      submission = submission_fixture()
      assert {:error, %Ecto.Changeset{}} = Problems.update_submission(submission, @invalid_attrs)
      assert submission == Problems.get_submission!(submission.id)
    end

    test "delete_submission/1 deletes the submission" do
      submission = submission_fixture()
      assert {:ok, %Submission{}} = Problems.delete_submission(submission)
      assert_raise Ecto.NoResultsError, fn -> Problems.get_submission!(submission.id) end
    end

    test "change_submission/1 returns a submission changeset" do
      submission = submission_fixture()
      assert %Ecto.Changeset{} = Problems.change_submission(submission)
    end
  end
end
