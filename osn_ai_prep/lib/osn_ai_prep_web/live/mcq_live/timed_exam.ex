defmodule OsnAiPrepWeb.McqLive.TimedExam do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Mcq
  alias OsnAiPrep.Subscriptions.Paywall

  @exam_duration_seconds 3 * 60 * 60  # 3 hours
  @questions_count 100  # Use 100 for now (would be 300 for real NOAI)

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    # Check premium access for full exam
    if Paywall.has_premium?(user) do
      {:ok,
       socket
       |> assign(:page_title, "Timed Exam")
       |> assign(:user, user)
       |> assign(:exam_started, false)
       |> assign(:exam_finished, false)
       |> assign(:questions, [])
       |> assign(:current_index, 0)
       |> assign(:answers, %{})
       |> assign(:marked_for_review, MapSet.new())
       |> assign(:time_remaining, @exam_duration_seconds)
       |> assign(:questions_count, @questions_count)
       |> assign(:session_id, nil)}
    else
      {:ok,
       socket
       |> put_flash(:error, "Timed exam requires a premium subscription")
       |> push_navigate(to: ~p"/pricing")}
    end
  end

  @impl true
  def handle_event("start_exam", _params, socket) do
    questions = Mcq.get_random_questions(@questions_count)
    session_id = Mcq.generate_session_id()

    # Start the timer
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:noreply,
     socket
     |> assign(:exam_started, true)
     |> assign(:questions, questions)
     |> assign(:session_id, session_id)
     |> assign(:start_time, System.monotonic_time(:second))}
  end

  @impl true
  def handle_event("select_answer", %{"answer" => answer}, socket) do
    current_index = socket.assigns.current_index
    question = Enum.at(socket.assigns.questions, current_index)

    answers = Map.put(socket.assigns.answers, question.id, answer)
    {:noreply, assign(socket, :answers, answers)}
  end

  @impl true
  def handle_event("go_to_question", %{"index" => index}, socket) do
    index = String.to_integer(index)
    {:noreply, assign(socket, :current_index, index)}
  end

  @impl true
  def handle_event("next_question", _params, socket) do
    current_index = socket.assigns.current_index
    total = length(socket.assigns.questions)

    new_index = min(current_index + 1, total - 1)
    {:noreply, assign(socket, :current_index, new_index)}
  end

  @impl true
  def handle_event("prev_question", _params, socket) do
    current_index = socket.assigns.current_index
    new_index = max(current_index - 1, 0)
    {:noreply, assign(socket, :current_index, new_index)}
  end

  @impl true
  def handle_event("toggle_mark_review", _params, socket) do
    current_index = socket.assigns.current_index
    question = Enum.at(socket.assigns.questions, current_index)
    marked = socket.assigns.marked_for_review

    new_marked =
      if MapSet.member?(marked, question.id) do
        MapSet.delete(marked, question.id)
      else
        MapSet.put(marked, question.id)
      end

    {:noreply, assign(socket, :marked_for_review, new_marked)}
  end

  @impl true
  def handle_event("submit_exam", _params, socket) do
    submit_all_answers(socket)
  end

  @impl true
  def handle_info(:tick, socket) do
    time_remaining = socket.assigns.time_remaining - 1

    if time_remaining <= 0 do
      # Time's up - auto submit
      submit_all_answers(socket)
    else
      {:noreply, assign(socket, :time_remaining, time_remaining)}
    end
  end

  defp submit_all_answers(socket) do
    user = socket.assigns.user
    questions = socket.assigns.questions
    answers = socket.assigns.answers
    session_id = socket.assigns.session_id

    # Submit all answers
    results =
      Enum.map(questions, fn question ->
        answer = answers[question.id]
        if answer do
          {:ok, attempt} = Mcq.submit_answer(user.id, question.id, answer, session_id)
          {question.id, attempt}
        else
          {question.id, nil}
        end
      end)
      |> Map.new()

    {:noreply,
     socket
     |> assign(:exam_finished, true)
     |> assign(:results, results)}
  end

  defp format_time(seconds) when seconds < 0, do: "00:00:00"
  defp format_time(seconds) do
    hours = div(seconds, 3600)
    minutes = div(rem(seconds, 3600), 60)
    secs = rem(seconds, 60)

    :io_lib.format("~2..0B:~2..0B:~2..0B", [hours, minutes, secs])
    |> IO.iodata_to_binary()
  end

  defp question_status(question, answers, marked_for_review) do
    cond do
      MapSet.member?(marked_for_review, question.id) -> :marked
      Map.has_key?(answers, question.id) -> :answered
      true -> :unanswered
    end
  end

  defp status_color(:marked), do: "bg-yellow-500 text-white"
  defp status_color(:answered), do: "bg-green-500 text-white"
  defp status_color(:unanswered), do: "bg-gray-200 text-gray-700"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100">
      <%= cond do %>
        <% @exam_finished -> %>
          <.exam_results
            questions={@questions}
            answers={@answers}
            results={@results}
          />
        <% @exam_started -> %>
          <.exam_interface
            questions={@questions}
            current_index={@current_index}
            answers={@answers}
            marked_for_review={@marked_for_review}
            time_remaining={@time_remaining}
          />
        <% true -> %>
          <.exam_intro questions_count={@questions_count} />
      <% end %>
    </div>
    """
  end

  defp exam_intro(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto px-4 py-16">
      <div class="bg-white rounded-2xl shadow-lg p-8">
        <div class="text-center mb-8">
          <div class="inline-flex items-center justify-center w-16 h-16 bg-purple-100 rounded-full mb-4">
            <svg class="w-8 h-8 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h1 class="text-3xl font-bold text-gray-900">Timed Exam Mode</h1>
          <p class="mt-2 text-lg text-gray-600">Simulate the NOAI Preliminary Round</p>
        </div>

        <div class="bg-gray-50 rounded-xl p-6 mb-8">
          <h2 class="font-semibold text-gray-900 mb-4">Exam Details</h2>
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span class="text-gray-500">Duration:</span>
              <span class="ml-2 font-medium">3 hours</span>
            </div>
            <div>
              <span class="text-gray-500">Questions:</span>
              <span class="ml-2 font-medium"><%= @questions_count || 100 %> MCQ</span>
            </div>
            <div>
              <span class="text-gray-500">Format:</span>
              <span class="ml-2 font-medium">Multiple Choice</span>
            </div>
            <div>
              <span class="text-gray-500">Topics:</span>
              <span class="ml-2 font-medium">All AI/ML topics</span>
            </div>
          </div>
        </div>

        <div class="bg-amber-50 border border-amber-200 rounded-xl p-4 mb-8">
          <div class="flex">
            <svg class="w-5 h-5 text-amber-500 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-amber-800">Important</h3>
              <p class="text-sm text-amber-700 mt-1">
                Once you start, the timer cannot be paused. Make sure you have 3 hours of uninterrupted time.
              </p>
            </div>
          </div>
        </div>

        <div class="flex justify-center gap-4">
          <.link navigate={~p"/mcq"} class="px-6 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition">
            Back to MCQ
          </.link>
          <button
            phx-click="start_exam"
            class="px-8 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition font-medium"
          >
            Start Exam
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp exam_interface(assigns) do
    current_question = Enum.at(assigns.questions, assigns.current_index)
    total_questions = length(assigns.questions)

    assigns =
      assigns
      |> assign(:current_question, current_question)
      |> assign(:total_questions, total_questions)

    ~H"""
    <div class="flex h-screen">
      <!-- Question Navigation Sidebar -->
      <div class="w-64 bg-white border-r border-gray-200 flex flex-col">
        <!-- Timer -->
        <div class={"p-4 border-b border-gray-200 #{if @time_remaining < 600, do: "bg-red-50", else: "bg-purple-50"}"}>
          <div class="text-center">
            <p class="text-xs text-gray-500 uppercase tracking-wide">Time Remaining</p>
            <p class={"text-2xl font-mono font-bold #{if @time_remaining < 600, do: "text-red-600", else: "text-purple-600"}"}>
              <%= format_time(@time_remaining) %>
            </p>
          </div>
        </div>

        <!-- Question Grid -->
        <div class="flex-1 overflow-y-auto p-4">
          <p class="text-xs text-gray-500 uppercase tracking-wide mb-3">Questions</p>
          <div class="grid grid-cols-5 gap-2">
            <%= for {question, index} <- Enum.with_index(@questions) do %>
              <button
                phx-click="go_to_question"
                phx-value-index={index}
                class={"w-8 h-8 rounded text-xs font-medium transition #{status_color(question_status(question, @answers, @marked_for_review))} #{if index == @current_index, do: "ring-2 ring-purple-500 ring-offset-1", else: ""}"}
              >
                <%= index + 1 %>
              </button>
            <% end %>
          </div>
        </div>

        <!-- Legend -->
        <div class="p-4 border-t border-gray-200 space-y-2 text-xs">
          <div class="flex items-center gap-2">
            <div class="w-4 h-4 rounded bg-green-500"></div>
            <span class="text-gray-600">Answered</span>
          </div>
          <div class="flex items-center gap-2">
            <div class="w-4 h-4 rounded bg-yellow-500"></div>
            <span class="text-gray-600">Marked for review</span>
          </div>
          <div class="flex items-center gap-2">
            <div class="w-4 h-4 rounded bg-gray-200"></div>
            <span class="text-gray-600">Not answered</span>
          </div>
        </div>

        <!-- Submit Button -->
        <div class="p-4 border-t border-gray-200">
          <button
            phx-click="submit_exam"
            data-confirm="Are you sure you want to submit? You cannot change your answers after submission."
            class="w-full py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition text-sm font-medium"
          >
            Submit Exam
          </button>
        </div>
      </div>

      <!-- Main Question Area -->
      <div class="flex-1 flex flex-col">
        <!-- Question Header -->
        <div class="bg-white border-b border-gray-200 px-8 py-4">
          <div class="flex items-center justify-between">
            <div>
              <span class="text-sm text-gray-500">Question <%= @current_index + 1 %> of <%= @total_questions %></span>
              <span class="ml-4 px-2 py-1 rounded text-xs font-medium bg-gray-100 text-gray-700">
                <%= @current_question.topic |> String.replace("_", " ") |> String.capitalize() %>
              </span>
            </div>
            <button
              phx-click="toggle_mark_review"
              class={"flex items-center gap-1 px-3 py-1 rounded text-sm transition #{if MapSet.member?(@marked_for_review, @current_question.id), do: "bg-yellow-100 text-yellow-700", else: "bg-gray-100 text-gray-600 hover:bg-gray-200"}"}
            >
              <svg class="w-4 h-4" fill={if MapSet.member?(@marked_for_review, @current_question.id), do: "currentColor", else: "none"} viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
              </svg>
              Mark for Review
            </button>
          </div>
        </div>

        <!-- Question Content -->
        <div class="flex-1 overflow-y-auto p-8">
          <div class="max-w-3xl mx-auto">
            <h2 class="text-xl font-medium text-gray-900 mb-8">
              <%= @current_question.question_en %>
            </h2>

            <div class="space-y-3">
              <%= for {option, label} <- [{"A", @current_question.option_a_en}, {"B", @current_question.option_b_en}, {"C", @current_question.option_c_en}, {"D", @current_question.option_d_en}] do %>
                <button
                  phx-click="select_answer"
                  phx-value-answer={option}
                  class={"w-full p-4 rounded-lg border-2 text-left transition flex items-center #{if @answers[@current_question.id] == option, do: "border-purple-500 bg-purple-50", else: "border-gray-200 hover:border-purple-300 hover:bg-purple-50"}"}
                >
                  <span class={"flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center mr-3 font-medium #{if @answers[@current_question.id] == option, do: "bg-purple-500 text-white", else: "bg-gray-200 text-gray-700"}"}>
                    <%= option %>
                  </span>
                  <span><%= label %></span>
                </button>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Navigation Footer -->
        <div class="bg-white border-t border-gray-200 px-8 py-4">
          <div class="flex justify-between max-w-3xl mx-auto">
            <button
              phx-click="prev_question"
              disabled={@current_index == 0}
              class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Previous
            </button>
            <button
              phx-click="next_question"
              disabled={@current_index == @total_questions - 1}
              class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Next
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp exam_results(assigns) do
    answered_count = map_size(assigns.answers)
    total_count = length(assigns.questions)
    correct_count = Enum.count(assigns.results, fn {_id, attempt} -> attempt && attempt.is_correct end)
    accuracy = if answered_count > 0, do: round(correct_count / answered_count * 100), else: 0

    assigns =
      assigns
      |> assign(:answered_count, answered_count)
      |> assign(:total_count, total_count)
      |> assign(:correct_count, correct_count)
      |> assign(:accuracy, accuracy)

    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-16">
      <div class="bg-white rounded-2xl shadow-lg p-8">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-gray-900">Exam Complete!</h1>
          <p class="mt-2 text-gray-600">Here are your results</p>
        </div>

        <!-- Score Cards -->
        <div class="grid grid-cols-3 gap-6 mb-8">
          <div class="bg-gray-50 rounded-xl p-6 text-center">
            <p class="text-4xl font-bold text-gray-900"><%= @answered_count %>/<%= @total_count %></p>
            <p class="text-sm text-gray-500 mt-1">Questions Answered</p>
          </div>
          <div class="bg-green-50 rounded-xl p-6 text-center">
            <p class="text-4xl font-bold text-green-600"><%= @correct_count %></p>
            <p class="text-sm text-gray-500 mt-1">Correct Answers</p>
          </div>
          <div class={"rounded-xl p-6 text-center #{if @accuracy >= 70, do: "bg-green-50", else: "bg-amber-50"}"}>
            <p class={"text-4xl font-bold #{if @accuracy >= 70, do: "text-green-600", else: "text-amber-600"}"}><%= @accuracy %>%</p>
            <p class="text-sm text-gray-500 mt-1">Accuracy</p>
          </div>
        </div>

        <!-- Performance Message -->
        <div class="text-center mb-8">
          <p class="text-lg text-gray-700">
            <%= cond do %>
              <% @accuracy >= 90 -> %>
                Outstanding! You're ready for the competition!
              <% @accuracy >= 70 -> %>
                Great job! Keep practicing to perfect your skills.
              <% @accuracy >= 50 -> %>
                Good effort! Review the topics you struggled with.
              <% true -> %>
                Keep studying! Focus on understanding the fundamentals.
            <% end %>
          </p>
        </div>

        <!-- Actions -->
        <div class="flex justify-center gap-4">
          <.link navigate={~p"/mcq"} class="px-6 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition">
            Back to MCQ
          </.link>
          <.link navigate={~p"/mcq/timed"} class="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition">
            Try Again
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
