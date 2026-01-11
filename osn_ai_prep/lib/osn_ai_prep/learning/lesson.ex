defmodule OsnAiPrep.Learning.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema for learning lessons.

  Lessons are organized by section and cover specific AI/ML topics.
  Content supports bilingual (EN/ID) and includes:
  - Concept explanations
  - Visual content references
  - Code examples
  - Quiz questions
  """

  schema "lessons" do
    field :title_en, :string
    field :title_id, :string
    field :description_en, :string
    field :description_id, :string
    field :content_en, :string
    field :content_id, :string

    # Organization
    field :section, :string  # e.g., "python_basics", "ml_fundamentals", "deep_learning"
    field :order, :integer   # Order within section

    # Metadata
    field :difficulty, :string  # "beginner", "intermediate", "advanced"
    field :estimated_minutes, :integer
    field :topic, :string  # For filtering and categorization

    # Resources
    field :video_url, :string
    field :colab_url, :string
    field :external_links, {:array, :map}, default: []

    # Free tier access
    field :is_free, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @required_fields [:title_en, :section, :order, :difficulty]
  @optional_fields [
    :title_id, :description_en, :description_id, :content_en, :content_id,
    :estimated_minutes, :topic, :video_url, :colab_url, :external_links, :is_free
  ]

  @doc false
  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:difficulty, ["beginner", "intermediate", "advanced"])
    |> validate_inclusion(:section, [
      "python_basics",
      "ml_fundamentals",
      "neural_networks",
      "deep_learning",
      "computer_vision",
      "nlp",
      "advanced_topics"
    ])
    |> validate_number(:order, greater_than: 0)
    |> validate_number(:estimated_minutes, greater_than: 0)
  end
end
