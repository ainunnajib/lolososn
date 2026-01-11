defmodule OsnAiPrepWeb.LessonLive.Show do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Learning

  @time_update_interval 30_000  # Update time every 30 seconds

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    lesson = Learning.get_lesson!(id)

    # Check access
    user = socket.assigns[:current_user]
    can_access = if user, do: Learning.can_access_lesson?(user, lesson), else: lesson.is_free || lesson.order <= 3

    # Get progress if logged in
    progress = if user, do: Learning.get_progress(user.id, lesson.id), else: nil

    # Get next lesson
    next_lesson = Learning.get_next_lesson(lesson)

    # Start time tracking if logged in
    if connected?(socket) && user && can_access do
      :timer.send_interval(@time_update_interval, self(), :update_time)
    end

    {:ok,
     assign(socket,
       page_title: lesson.title_en,
       lesson: lesson,
       can_access: can_access,
       progress: progress,
       next_lesson: next_lesson,
       show_completion_modal: false,
       locale: get_locale(socket)
     )}
  end

  defp get_locale(socket) do
    socket.assigns[:locale] || "en"
  end

  defp get_title(lesson, locale) do
    if locale == "id" && lesson.title_id, do: lesson.title_id, else: lesson.title_en
  end

  defp get_description(lesson, locale) do
    if locale == "id" && lesson.description_id, do: lesson.description_id, else: lesson.description_en
  end

  defp get_content(lesson, locale) do
    if locale == "id" && lesson.content_id, do: lesson.content_id, else: lesson.content_en
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

  defp difficulty_color(difficulty) do
    %{
      "beginner" => "badge-success",
      "intermediate" => "badge-warning",
      "advanced" => "badge-error"
    }[difficulty] || "badge-ghost"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <!-- Breadcrumb -->
      <div class="breadcrumbs text-sm mb-4">
        <ul>
          <li><.link navigate={~p"/lessons"}>{gettext("Lessons")}</.link></li>
          <li><.link navigate={~p"/lessons?section=#{@lesson.section}"}>{section_title(@lesson.section)}</.link></li>
          <li>{get_title(@lesson, @locale)}</li>
        </ul>
      </div>

      <!-- Access Denied -->
      <div :if={!@can_access} class="card bg-warning/10 border border-warning mb-8">
        <div class="card-body text-center">
          <.icon name="hero-lock-closed" class="w-16 h-16 mx-auto text-warning mb-4" />
          <h2 class="text-2xl font-bold mb-2">{gettext("Premium Content")}</h2>
          <p class="text-base-content/70 mb-4">
            {gettext("This lesson is available for premium subscribers. Upgrade to access all lessons and features.")}
          </p>
          <.link navigate={~p"/pricing"} class="btn btn-warning">
            {gettext("Upgrade to Premium")}
          </.link>
        </div>
      </div>

      <!-- Lesson Content -->
      <div :if={@can_access}>
        <!-- Header -->
        <div class="mb-8">
          <div class="flex flex-wrap gap-2 mb-2">
            <span class={"badge #{difficulty_color(@lesson.difficulty)}"}>
              {@lesson.difficulty}
            </span>
            <span :if={@lesson.estimated_minutes} class="badge badge-ghost gap-1">
              <.icon name="hero-clock" class="w-4 h-4" />
              {@lesson.estimated_minutes} {gettext("min")}
            </span>
            <span :if={@lesson.topic} class="badge badge-outline">
              {@lesson.topic}
            </span>
          </div>

          <h1 class="text-3xl font-bold mb-2">{get_title(@lesson, @locale)}</h1>

          <p :if={get_description(@lesson, @locale)} class="text-lg text-base-content/70">
            {get_description(@lesson, @locale)}
          </p>
        </div>

        <!-- Progress indicator -->
        <div :if={@progress && @progress.completed} class="alert alert-success mb-6">
          <.icon name="hero-check-circle" class="w-6 h-6" />
          <div>
            <div class="font-semibold">{gettext("Completed!")}</div>
            <div :if={@progress.quiz_score} class="text-sm">
              {gettext("Quiz score")}: {@progress.quiz_score}%
            </div>
          </div>
        </div>

        <!-- Main Content -->
        <div class="prose prose-lg max-w-none mb-8">
          <div :if={get_content(@lesson, @locale)}>
            {raw(render_markdown(get_content(@lesson, @locale)))}
          </div>
          <div :if={!get_content(@lesson, @locale)} class="text-center py-8 text-base-content/50">
            <.icon name="hero-document-text" class="w-12 h-12 mx-auto mb-2" />
            <p>{gettext("Content coming soon...")}</p>
          </div>
        </div>

        <!-- Resources -->
        <div :if={@lesson.video_url || @lesson.colab_url || @lesson.external_links != []} class="card bg-base-200 mb-8">
          <div class="card-body">
            <h3 class="card-title">
              <.icon name="hero-link" class="w-5 h-5" />
              {gettext("Resources")}
            </h3>

            <div class="flex flex-wrap gap-3">
              <a
                :if={@lesson.video_url}
                href={@lesson.video_url}
                target="_blank"
                rel="noopener"
                class="btn btn-outline btn-info gap-2"
              >
                <.icon name="hero-play" class="w-5 h-5" />
                {gettext("Watch Video")}
              </a>

              <a
                :if={@lesson.colab_url}
                href={@lesson.colab_url}
                target="_blank"
                rel="noopener"
                class="btn btn-outline btn-success gap-2"
              >
                <.icon name="hero-code-bracket" class="w-5 h-5" />
                {gettext("Open in Colab")}
              </a>

              <a
                :for={link <- @lesson.external_links}
                href={link["url"]}
                target="_blank"
                rel="noopener"
                class="btn btn-outline btn-ghost gap-2"
              >
                <.icon name="hero-arrow-top-right-on-square" class="w-5 h-5" />
                {link["title"] || gettext("External Link")}
              </a>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex flex-wrap justify-between items-center gap-4 pt-4 border-t border-base-300">
          <.link navigate={~p"/lessons"} class="btn btn-ghost gap-2">
            <.icon name="hero-arrow-left" class="w-5 h-5" />
            {gettext("Back to Lessons")}
          </.link>

          <div class="flex gap-2">
            <button
              :if={@current_user && !(@progress && @progress.completed)}
              phx-click="mark_complete"
              class="btn btn-primary gap-2"
            >
              <.icon name="hero-check" class="w-5 h-5" />
              {gettext("Mark as Complete")}
            </button>

            <.link
              :if={@next_lesson}
              navigate={~p"/lessons/#{@next_lesson.id}"}
              class="btn btn-accent gap-2"
            >
              {gettext("Next Lesson")}
              <.icon name="hero-arrow-right" class="w-5 h-5" />
            </.link>
          </div>
        </div>
      </div>

      <!-- Completion Modal -->
      <div :if={@show_completion_modal} class="modal modal-open">
        <div class="modal-box text-center">
          <div class="text-6xl mb-4">🎉</div>
          <h3 class="font-bold text-2xl mb-2">{gettext("Lesson Complete!")}</h3>
          <p class="py-4 text-base-content/70">
            {gettext("Great job! You've completed this lesson.")}
          </p>
          <div class="modal-action justify-center">
            <button phx-click="close_modal" class="btn btn-ghost">
              {gettext("Stay Here")}
            </button>
            <.link :if={@next_lesson} navigate={~p"/lessons/#{@next_lesson.id}"} class="btn btn-primary">
              {gettext("Next Lesson")}
            </.link>
          </div>
        </div>
        <div class="modal-backdrop" phx-click="close_modal"></div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("mark_complete", _params, socket) do
    user = socket.assigns.current_user
    lesson = socket.assigns.lesson

    case Learning.complete_lesson(user.id, lesson.id) do
      {:ok, progress} ->
        {:noreply,
         socket
         |> assign(progress: progress, show_completion_modal: true)
         |> put_flash(:info, gettext("Lesson marked as complete!"))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to mark lesson as complete."))}
    end
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_completion_modal: false)}
  end

  @impl true
  def handle_info(:update_time, socket) do
    user = socket.assigns[:current_user]
    lesson = socket.assigns.lesson

    if user do
      # Update time spent (30 seconds = interval)
      Learning.update_time_spent(user.id, lesson.id, 30)
    end

    {:noreply, socket}
  end

  defp render_markdown(content) when is_binary(content) do
    case Earmark.as_html(content) do
      {:ok, html, _} -> html
      {:error, _, _} -> content
    end
  end

  defp render_markdown(_), do: ""
end
