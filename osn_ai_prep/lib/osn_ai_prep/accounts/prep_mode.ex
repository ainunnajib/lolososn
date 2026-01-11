defmodule OsnAiPrep.Accounts.PrepMode do
  @moduledoc """
  Defines the competition preparation modes available to users.

  Each mode customizes the learning experience based on the target competition:
  - noai_prelim: Singapore NOAI Preliminary (300 MCQ focus)
  - noai_final: Singapore NOAI Final (MCQ + Coding mix)
  - osn_ai: Indonesia OSN AI / Pelatnas (Essay + Coding focus)
  - ioai: International IOAI (Advanced problems)
  """

  @modes %{
    "noai_prelim" => %{
      name: "NOAI Preliminary",
      name_id: "NOAI Babak Penyisihan",
      country: "SG",
      focus: :mcq,
      difficulty: 2,
      duration_days: 14,
      description: "Focus on MCQ practice (300 questions) for Singapore NOAI Preliminary",
      description_id: "Fokus latihan pilihan ganda (300 soal) untuk NOAI Penyisihan Singapura",
      features: [:mcq_first, :breadth_focus, :recall_emphasis]
    },
    "noai_final" => %{
      name: "NOAI Final",
      name_id: "NOAI Babak Final",
      country: "SG",
      focus: :mixed,
      difficulty: 3,
      duration_days: 14,
      description: "Balanced MCQ + Coding preparation for Singapore NOAI Final",
      description_id: "Persiapan seimbang pilihan ganda + coding untuk NOAI Final Singapura",
      features: [:mcq_and_coding, :applied_problems, :balanced_approach]
    },
    "osn_ai" => %{
      name: "OSN AI / Pelatnas",
      name_id: "OSN AI / Pelatnas",
      country: "ID",
      focus: :coding,
      difficulty: 3,
      duration_days: 14,
      description: "Essay + Python coding focus for Indonesia OSN AI national selection",
      description_id: "Fokus esai + coding Python untuk seleksi nasional OSN AI Indonesia",
      features: [:theory_and_code, :essay_questions, :python_implementation]
    },
    "ioai" => %{
      name: "IOAI Preparation",
      name_id: "Persiapan IOAI",
      country: "International",
      focus: :advanced,
      difficulty: 5,
      duration_days: 30,
      description: "Advanced problems for International Olympiad in AI preparation",
      description_id: "Soal-soal tingkat lanjut untuk persiapan Olimpiade Internasional AI",
      features: [:advanced_only, :research_level, :novel_applications]
    }
  }

  @doc """
  Returns the configuration for a specific prep mode.
  """
  def get(mode) when is_binary(mode), do: @modes[mode]
  def get(_), do: nil

  @doc """
  Returns all available prep modes.
  """
  def all, do: @modes

  @doc """
  Returns a list of all mode keys.
  """
  def keys, do: Map.keys(@modes)

  @doc """
  Checks if a mode key is valid.
  """
  def valid?(mode), do: Map.has_key?(@modes, mode)

  @doc """
  Returns the default prep mode.
  """
  def default, do: "noai_prelim"

  @doc """
  Returns modes for a specific country.
  """
  def for_country(country) do
    @modes
    |> Enum.filter(fn {_key, config} -> config.country == country end)
    |> Map.new()
  end

  @doc """
  Returns a list of modes suitable for selection UI.
  """
  def options do
    @modes
    |> Enum.map(fn {key, config} ->
      %{
        value: key,
        label: config.name,
        label_id: config.name_id,
        country: config.country,
        focus: config.focus,
        description: config.description,
        description_id: config.description_id
      }
    end)
    |> Enum.sort_by(& &1.value)
  end

  @doc """
  Returns the focus type for a mode.
  """
  def focus(mode) do
    case get(mode) do
      %{focus: focus} -> focus
      _ -> :mcq
    end
  end

  @doc """
  Returns the recommended content ordering based on mode.
  """
  def content_priority(mode) do
    case focus(mode) do
      :mcq -> [:mcq, :problems, :lessons]
      :mixed -> [:problems, :mcq, :lessons]
      :coding -> [:problems, :lessons, :mcq]
      :advanced -> [:problems, :lessons, :mcq]
    end
  end

  @doc """
  Returns the difficulty level (1-5) for a mode.
  """
  def difficulty(mode) do
    case get(mode) do
      %{difficulty: d} -> d
      _ -> 2
    end
  end

  @doc """
  Returns whether a mode emphasizes MCQ practice.
  """
  def mcq_focused?(mode) do
    focus(mode) in [:mcq, :mixed]
  end

  @doc """
  Returns whether a mode emphasizes coding.
  """
  def coding_focused?(mode) do
    focus(mode) in [:coding, :advanced, :mixed]
  end
end
