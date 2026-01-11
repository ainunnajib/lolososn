defmodule OsnAiPrepWeb.LessonLive.Index do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Learning

  @impl true
  def mount(_params, _session, socket) do
    lessons = Learning.list_lessons()
    grouped_lessons = group_lessons_by_section(lessons)

    user_stats =
      if socket.assigns[:current_user] do
        Learning.get_user_stats(socket.assigns.current_user.id)
      else
        nil
      end

    {:ok,
     assign(socket,
       page_title: gettext("Learning Modules"),
       lessons: lessons,
       grouped_lessons: grouped_lessons,
       user_stats: user_stats,
       selected_section: nil,
       filter_difficulty: nil
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    section = params["section"]
    difficulty = params["difficulty"]

    filters = []
    filters = if section, do: [{:section, section} | filters], else: filters
    filters = if difficulty, do: [{:difficulty, difficulty} | filters], else: filters

    lessons = Learning.list_lessons(filters)
    grouped_lessons = group_lessons_by_section(lessons)

    {:noreply,
     assign(socket,
       selected_section: section,
       filter_difficulty: difficulty,
       lessons: lessons,
       grouped_lessons: grouped_lessons
     )}
  end

  defp group_lessons_by_section(lessons) do
    lessons
    |> Enum.group_by(& &1.section)
    |> Enum.sort_by(fn {section, _} -> section_order(section) end)
  end

  defp section_order(section) do
    %{
      "python_basics" => 1,
      "ml_fundamentals" => 2,
      "neural_networks" => 3,
      "deep_learning" => 4,
      "computer_vision" => 5,
      "nlp" => 6,
      "advanced_topics" => 7
    }[section] || 99
  end

  defp section_title(section) do
    %{
      "python_basics" => gettext("Python Basics"),
      "ml_fundamentals" => gettext("ML Fundamentals"),
      "neural_networks" => gettext("Neural Networks"),
      "deep_learning" => gettext("Deep Learning"),
      "computer_vision" => gettext("Computer Vision"),
      "nlp" => gettext("Natural Language Processing"),
      "advanced_topics" => gettext("Advanced Topics")
    }[section] || section
  end

  defp section_icon(section) do
    %{
      "python_basics" => "hero-code-bracket",
      "ml_fundamentals" => "hero-chart-bar",
      "neural_networks" => "hero-cpu-chip",
      "deep_learning" => "hero-cube-transparent",
      "computer_vision" => "hero-eye",
      "nlp" => "hero-chat-bubble-left-right",
      "advanced_topics" => "hero-rocket-launch"
    }[section] || "hero-academic-cap"
  end

  defp difficulty_color(difficulty) do
    %{
      "beginner" => "badge-success",
      "intermediate" => "badge-warning",
      "advanced" => "badge-error"
    }[difficulty] || "badge-ghost"
  end

  defp can_access?(socket, lesson) do
    user = socket.assigns[:current_user]

    cond do
      is_nil(user) -> lesson.is_free || lesson.order <= 3
      true -> Learning.can_access_lesson?(user, lesson)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold mb-2">{gettext("Learning Modules")}</h1>
        <p class="text-base-content/70">
          {gettext("Master AI/ML concepts from basics to advanced topics")}
        </p>
      </div>

      <!-- Progress Overview (if logged in) -->
      <div :if={@user_stats} class="mb-8">
        <div class="stats stats-vertical lg:stats-horizontal shadow w-full bg-base-200">
          <div class="stat">
            <div class="stat-figure text-primary">
              <.icon name="hero-academic-cap" class="w-8 h-8" />
            </div>
            <div class="stat-title">{gettext("Progress")}</div>
            <div class="stat-value text-primary">{@user_stats.completion_percentage}%</div>
            <div class="stat-desc">
              {@user_stats.completed_lessons}/{@user_stats.total_lessons} {gettext("lessons")}
            </div>
          </div>

          <div class="stat">
            <div class="stat-figure text-secondary">
              <.icon name="hero-clock" class="w-8 h-8" />
            </div>
            <div class="stat-title">{gettext("Time Spent")}</div>
            <div class="stat-value text-secondary">{format_time(@user_stats.total_time_seconds)}</div>
            <div class="stat-desc">{gettext("Total learning time")}</div>
          </div>

          <div :if={@user_stats.average_quiz_score} class="stat">
            <div class="stat-figure text-accent">
              <.icon name="hero-trophy" class="w-8 h-8" />
            </div>
            <div class="stat-title">{gettext("Avg Quiz Score")}</div>
            <div class="stat-value text-accent">{@user_stats.average_quiz_score}%</div>
            <div class="stat-desc">{gettext("Keep it up!")}</div>
          </div>
        </div>
      </div>

      <!-- Filters -->
      <div class="flex flex-wrap gap-4 mb-6">
        <div class="form-control">
          <label class="label">
            <span class="label-text">{gettext("Section")}</span>
          </label>
          <select
            class="select select-bordered w-full max-w-xs"
            phx-change="filter"
            name="section"
          >
            <option value="">{gettext("All Sections")}</option>
            <option :for={{section, _} <- @grouped_lessons} value={section} selected={@selected_section == section}>
              {section_title(section)}
            </option>
          </select>
        </div>

        <div class="form-control">
          <label class="label">
            <span class="label-text">{gettext("Difficulty")}</span>
          </label>
          <select
            class="select select-bordered w-full max-w-xs"
            phx-change="filter"
            name="difficulty"
          >
            <option value="">{gettext("All Difficulties")}</option>
            <option value="beginner" selected={@filter_difficulty == "beginner"}>{gettext("Beginner")}</option>
            <option value="intermediate" selected={@filter_difficulty == "intermediate"}>{gettext("Intermediate")}</option>
            <option value="advanced" selected={@filter_difficulty == "advanced"}>{gettext("Advanced")}</option>
          </select>
        </div>
      </div>

      <!-- Lessons by Section -->
      <div class="space-y-8">
        <div :for={{section, lessons} <- @grouped_lessons} class="card bg-base-200 shadow-xl">
          <div class="card-body">
            <h2 class="card-title text-xl flex items-center gap-2">
              <.icon name={section_icon(section)} class="w-6 h-6" />
              {section_title(section)}
              <span class="badge badge-neutral">{length(lessons)} {gettext("lessons")}</span>
            </h2>

            <!-- Section Progress Bar -->
            <div :if={@user_stats && @user_stats.section_progress[section]} class="mb-4">
              <% section_prog = @user_stats.section_progress[section] %>
              <div class="flex justify-between text-sm mb-1">
                <span>{section_prog.completed}/{section_prog.total} {gettext("completed")}</span>
                <span>{round(section_prog.completed / section_prog.total * 100)}%</span>
              </div>
              <progress
                class="progress progress-primary w-full"
                value={section_prog.completed}
                max={section_prog.total}
              ></progress>
            </div>

            <!-- Lesson Cards -->
            <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              <.link
                :for={lesson <- Enum.sort_by(lessons, & &1.order)}
                navigate={~p"/lessons/#{lesson.id}"}
                class={"card bg-base-100 hover:shadow-lg transition-shadow cursor-pointer #{unless can_access?(@socket, lesson), do: "opacity-60"}"}
              >
                <div class="card-body p-4">
                  <div class="flex justify-between items-start">
                    <h3 class="font-semibold">{lesson.title_en}</h3>
                    <div :if={!can_access?(@socket, lesson)} class="badge badge-warning gap-1">
                      <.icon name="hero-lock-closed" class="w-3 h-3" />
                      {gettext("Premium")}
                    </div>
                  </div>

                  <p :if={lesson.description_en} class="text-sm text-base-content/70 line-clamp-2">
                    {lesson.description_en}
                  </p>

                  <div class="flex flex-wrap gap-2 mt-2">
                    <span class={"badge badge-sm #{difficulty_color(lesson.difficulty)}"}>
                      {lesson.difficulty}
                    </span>
                    <span :if={lesson.estimated_minutes} class="badge badge-sm badge-ghost gap-1">
                      <.icon name="hero-clock" class="w-3 h-3" />
                      {lesson.estimated_minutes} {gettext("min")}
                    </span>
                    <span :if={lesson.video_url} class="badge badge-sm badge-info gap-1">
                      <.icon name="hero-play" class="w-3 h-3" />
                      {gettext("Video")}
                    </span>
                    <span :if={lesson.colab_url} class="badge badge-sm badge-success gap-1">
                      <.icon name="hero-code-bracket" class="w-3 h-3" />
                      {gettext("Colab")}
                    </span>
                  </div>
                </div>
              </.link>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div :if={@lessons == []} class="text-center py-12">
        <.icon name="hero-academic-cap" class="w-16 h-16 mx-auto text-base-content/30 mb-4" />
        <h3 class="text-lg font-semibold mb-2">{gettext("No lessons found")}</h3>
        <p class="text-base-content/70">
          {gettext("Try adjusting your filters or check back later.")}
        </p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("filter", params, socket) do
    section = if params["section"] == "", do: nil, else: params["section"]
    difficulty = if params["difficulty"] == "", do: nil, else: params["difficulty"]

    path_params = %{}
    path_params = if section, do: Map.put(path_params, :section, section), else: path_params
    path_params = if difficulty, do: Map.put(path_params, :difficulty, difficulty), else: path_params

    {:noreply, push_patch(socket, to: ~p"/lessons?#{path_params}")}
  end

  defp format_time(seconds) when is_nil(seconds), do: "0m"
  defp format_time(seconds) when seconds < 60, do: "#{seconds}s"
  defp format_time(seconds) when seconds < 3600, do: "#{div(seconds, 60)}m"

  defp format_time(seconds) do
    hours = div(seconds, 3600)
    minutes = div(rem(seconds, 3600), 60)
    "#{hours}h #{minutes}m"
  end
end
