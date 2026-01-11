defmodule OsnAiPrep.McqTest do
  use OsnAiPrep.DataCase

  alias OsnAiPrep.Mcq

  describe "mcq_questions" do
    alias OsnAiPrep.Mcq.Question

    import OsnAiPrep.McqFixtures

    @invalid_attrs %{
      question_en: nil,
      option_a_en: nil,
      option_b_en: nil,
      option_c_en: nil,
      option_d_en: nil,
      correct_answer: nil,
      topic: nil,
      difficulty: nil
    }

    test "list_mcq_questions/0 returns all mcq_questions" do
      question = question_fixture()
      assert Mcq.list_mcq_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Mcq.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{
        question_en: "What is supervised learning?",
        question_id: "Apa itu supervised learning?",
        option_a_en: "Learning with labeled data",
        option_a_id: "Pembelajaran dengan data berlabel",
        option_b_en: "Learning without labels",
        option_b_id: "Pembelajaran tanpa label",
        option_c_en: "Learning by reinforcement",
        option_c_id: "Pembelajaran dengan penguatan",
        option_d_en: "Learning by imitation",
        option_d_id: "Pembelajaran dengan imitasi",
        correct_answer: "A",
        explanation_en: "Supervised learning uses labeled data to train models.",
        explanation_id: "Supervised learning menggunakan data berlabel untuk melatih model.",
        topic: "ml_basics",
        difficulty: "easy",
        competition: "noai_prelim"
      }

      assert {:ok, %Question{} = question} = Mcq.create_question(valid_attrs)
      assert question.question_en == "What is supervised learning?"
      assert question.correct_answer == "A"
      assert question.topic == "ml_basics"
      assert question.difficulty == "easy"
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mcq.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{
        question_en: "Updated question",
        difficulty: "hard"
      }

      assert {:ok, %Question{} = question} = Mcq.update_question(question, update_attrs)
      assert question.question_en == "Updated question"
      assert question.difficulty == "hard"
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Mcq.update_question(question, @invalid_attrs)
      assert question == Mcq.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Mcq.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Mcq.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Mcq.change_question(question)
    end
  end
end
