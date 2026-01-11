defmodule OsnAiPrep.McqFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OsnAiPrep.Mcq` context.
  """

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        question_en: "What is the purpose of dropout in neural networks?",
        question_id: "Apa tujuan dropout dalam neural network?",
        option_a_en: "To prevent overfitting",
        option_a_id: "Untuk mencegah overfitting",
        option_b_en: "To increase training speed",
        option_b_id: "Untuk meningkatkan kecepatan training",
        option_c_en: "To add more neurons",
        option_c_id: "Untuk menambah neuron",
        option_d_en: "To reduce model size",
        option_d_id: "Untuk mengurangi ukuran model",
        correct_answer: "A",
        explanation_en: "Dropout randomly sets neurons to zero during training to prevent overfitting.",
        explanation_id: "Dropout secara acak menetapkan neuron ke nol selama training untuk mencegah overfitting.",
        topic: "neural_networks",
        difficulty: "medium",
        competition: "noai_prelim"
      })
      |> OsnAiPrep.Mcq.create_question()

    question
  end
end
