defmodule OsnAiPrepWeb.McqLive.Quiz do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Mcq
  alias OsnAiPrep.Subscriptions.Paywall

  @impl true
  def mount(params, _session, socket) do
    user = socket.assigns.current_scope.user

    # Parse filters from params
    count = String.to_integer(params["count"] || "10")
    filters = build_filters(params)

    # Check access
    attempts_count = Mcq.count_user_attempts(user.id)
    mcq_access = Paywall.mcq_access(user, attempts_count)

    # Get questions
    questions = Mcq.get_random_questions(count, filters)
    session_id = Mcq.generate_session_id()

    if Enum.empty?(questions) do
      {:ok,
       socket
       |> put_flash(:error, "No questions found with the selected filters")
       |> push_navigate(to: ~p"/mcq")}
    else
      {:ok,
       socket
       |> assign(:page_title, "MCQ Quiz")
       |> assign(:user, user)
       |> assign(:questions, questions)
       |> assign(:session_id, session_id)
       |> assign(:current_index, 0)
       |> assign(:answers, %{})
       |> assign(:results, %{})
       |> assign(:quiz_complete, false)
       |> assign(:show_explanation, false)
       |> assign(:mcq_access, mcq_access)
       |> assign(:start_time, System.monotonic_time(:second))}
    end
  end

  defp build_filters(params) do
    %{}
    |> maybe_add_filter(:topic, params["topic"])
    |> maybe_add_filter(:difficulty, params["difficulty"])
  end

  defp maybe_add_filter(filters, _key, nil), do: filters
  defp maybe_add_filter(filters, _key, ""), do: filters
  defp maybe_add_filter(filters, key, value), do: Map.put(filters, key, value)

  @impl true
  def handle_event("select_answer", %{"answer" => answer}, socket) do
    current_index = socket.assigns.current_index
    question = Enum.at(socket.assigns.questions, current_index)

    # Record the answer
    answers = Map.put(socket.assigns.answers, question.id, answer)

    {:noreply, assign(socket, :answers, answers)}
  end

  @impl true
  def handle_event("submit_answer", _params, socket) do
    current_index = socket.assigns.current_index
    question = Enum.at(socket.assigns.questions, current_index)
    selected_answer = socket.assigns.answers[question.id]

    if selected_answer do
      # Calculate time taken for this question
      time_taken = System.monotonic_time(:second) - socket.assigns.start_time

      # Submit the answer
      {:ok, attempt} =
        Mcq.submit_answer(
          socket.assigns.user.id,
          question.id,
          selected_answer,
          socket.assigns.session_id,
          time_taken
        )

      results = Map.put(socket.assigns.results, question.id, attempt)

      {:noreply,
       socket
       |> assign(:results, results)
       |> assign(:show_explanation, true)}
    else
      {:noreply, put_flash(socket, :error, "Please select an answer")}
    end
  end

  @impl true
  def handle_event("next_question", _params, socket) do
    current_index = socket.assigns.current_index
    total_questions = length(socket.assigns.questions)

    if current_index + 1 >= total_questions do
      # Quiz complete
      {:noreply,
       socket
       |> assign(:quiz_complete, true)
       |> assign(:show_explanation, false)}
    else
      {:noreply,
       socket
       |> assign(:current_index, current_index + 1)
       |> assign(:show_explanation, false)
       |> assign(:start_time, System.monotonic_time(:second))}
    end
  end

  @impl true
  def handle_event("finish_quiz", _params, socket) do
    {:noreply, assign(socket, :quiz_complete, true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <%= if @quiz_complete do %>
        <.quiz_results
          questions={@questions}
          results={@results}
          answers={@answers}
        />
      <% else %>
        <.quiz_question
          question={Enum.at(@questions, @current_index)}
          current_index={@current_index}
          total_questions={length(@questions)}
          selected_answer={@answers[Enum.at(@questions, @current_index).id]}
          result={@results[Enum.at(@questions, @current_index).id]}
          show_explanation={@show_explanation}
        />
      <% end %>
    </div>
    """
  end

  defp quiz_question(assigns) do
    ~H"""
    <div>
      <!-- Progress Bar -->
      <div class="mb-6">
        <div class="flex justify-between text-sm text-gray-600 mb-2">
          <span>Question <%= @current_index + 1 %> of <%= @total_questions %></span>
          <span><%= round((@current_index + 1) / @total_questions * 100) %>% complete</span>
        </div>
        <div class="w-full bg-gray-200 rounded-full h-2">
          <div
            class="bg-indigo-600 h-2 rounded-full transition-all duration-300"
            style={"width: #{(@current_index + 1) / @total_questions * 100}%"}
          >
          </div>
        </div>
      </div>

      <!-- Question Card -->
      <div class="bg-white rounded-lg shadow-lg p-8">
        <!-- Topic and Difficulty Badge -->
        <div class="flex items-center gap-2 mb-4">
          <span class="px-3 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-700">
            <%= topic_label(@question.topic) %>
          </span>
          <span class={"px-3 py-1 rounded-full text-xs font-medium #{difficulty_badge(@question.difficulty)}"}>
            <%= String.capitalize(@question.difficulty) %>
          </span>
        </div>

        <!-- Question Text -->
        <h2 class="text-xl font-semibold text-gray-900 mb-6">
          <%= @question.question_en %>
        </h2>

        <!-- Answer Options -->
        <div class="space-y-3">
          <%= for {option, label} <- [{"A", @question.option_a_en}, {"B", @question.option_b_en}, {"C", @question.option_c_en}, {"D", @question.option_d_en}] do %>
            <button
              phx-click="select_answer"
              phx-value-answer={option}
              disabled={@show_explanation}
              class={answer_button_class(@selected_answer, option, @result, @question.correct_answer, @show_explanation)}
            >
              <span class="flex items-center">
                <span class={"flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center mr-3 font-medium #{answer_circle_class(@selected_answer, option, @result, @question.correct_answer, @show_explanation)}"}>
                  <%= option %>
                </span>
                <span class="text-left"><%= label %></span>
              </span>
              <%= if @show_explanation do %>
                <%= if option == @question.correct_answer do %>
                  <svg class="w-5 h-5 text-green-500 ml-auto" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                <% end %>
                <%= if option == @selected_answer && option != @question.correct_answer do %>
                  <svg class="w-5 h-5 text-red-500 ml-auto" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                  </svg>
                <% end %>
              <% end %>
            </button>
          <% end %>
        </div>

        <!-- Explanation (shown after submitting) -->
        <%= if @show_explanation && @question.explanation_en do %>
          <div class="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <h3 class="font-medium text-blue-900 mb-2">Explanation</h3>
            <p class="text-blue-800"><%= @question.explanation_en %></p>
          </div>
        <% end %>

        <!-- Action Buttons -->
        <div class="mt-8 flex justify-between">
          <.link navigate={~p"/mcq"} class="text-gray-600 hover:text-gray-900">
            Exit Quiz
          </.link>

          <%= if @show_explanation do %>
            <button
              phx-click="next_question"
              class="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition"
            >
              <%= if @current_index + 1 >= @total_questions, do: "See Results", else: "Next Question" %>
            </button>
          <% else %>
            <button
              phx-click="submit_answer"
              disabled={@selected_answer == nil}
              class="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Submit Answer
            </button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp quiz_results(assigns) do
    correct_count = Enum.count(assigns.results, fn {_id, attempt} -> attempt.is_correct end)
    total_count = length(assigns.questions)
    accuracy = if total_count > 0, do: round(correct_count / total_count * 100), else: 0

    assigns =
      assigns
      |> assign(:correct_count, correct_count)
      |> assign(:total_count, total_count)
      |> assign(:accuracy, accuracy)

    ~H"""
    <div>
      <!-- Results Header -->
      <div class="bg-white rounded-lg shadow-lg p-8 text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-4">Quiz Complete!</h1>

        <div class="flex justify-center items-center gap-8 mb-6">
          <div>
            <p class="text-5xl font-bold text-indigo-600"><%= @correct_count %>/<%= @total_count %></p>
            <p class="text-gray-600">Correct Answers</p>
          </div>
          <div class="w-px h-16 bg-gray-200"></div>
          <div>
            <p class={"text-5xl font-bold #{if @accuracy >= 70, do: "text-green-600", else: "text-amber-600"}"}><%= @accuracy %>%</p>
            <p class="text-gray-600">Accuracy</p>
          </div>
        </div>

        <!-- Performance Message -->
        <p class="text-lg text-gray-700 mb-6">
          <%= cond do %>
            <% @accuracy >= 90 -> %>
              Excellent! You're well prepared for the competition!
            <% @accuracy >= 70 -> %>
              Good job! Keep practicing to improve further.
            <% @accuracy >= 50 -> %>
              Not bad! Review the explanations and try again.
            <% true -> %>
              Keep studying! Focus on the topics you struggled with.
          <% end %>
        </p>

        <div class="flex justify-center gap-4">
          <.link navigate={~p"/mcq"} class="px-6 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition">
            Back to MCQ Home
          </.link>
          <.link navigate={~p"/mcq/quiz"} class="px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition">
            Start New Quiz
          </.link>
        </div>
      </div>

      <!-- Question Review -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Question Review</h2>
        <div class="space-y-4">
          <%= for {question, index} <- Enum.with_index(@questions) do %>
            <% result = @results[question.id] %>
            <% user_answer = @answers[question.id] %>
            <div class={"p-4 rounded-lg border #{if result && result.is_correct, do: "border-green-200 bg-green-50", else: "border-red-200 bg-red-50"}"}>
              <div class="flex items-start justify-between">
                <div class="flex-1">
                  <p class="font-medium text-gray-900">
                    <%= index + 1 %>. <%= question.question_en %>
                  </p>
                  <p class="text-sm text-gray-600 mt-1">
                    Your answer: <span class="font-medium"><%= user_answer %></span>
                    <%= if result && !result.is_correct do %>
                      | Correct: <span class="font-medium text-green-700"><%= question.correct_answer %></span>
                    <% end %>
                  </p>
                </div>
                <%= if result && result.is_correct do %>
                  <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                <% else %>
                  <svg class="w-6 h-6 text-red-500 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                  </svg>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp topic_label(topic) do
    case topic do
      "python_basics" -> "Python Basics"
      "ml_basics" -> "ML Basics"
      "neural_networks" -> "Neural Networks"
      "computer_vision" -> "Computer Vision"
      "nlp" -> "NLP"
      "deep_learning" -> "Deep Learning"
      "transformers" -> "Transformers"
      "optimization" -> "Optimization"
      _ -> topic |> to_string() |> String.replace("_", " ") |> String.capitalize()
    end
  end

  defp difficulty_badge("easy"), do: "bg-green-100 text-green-700"
  defp difficulty_badge("medium"), do: "bg-yellow-100 text-yellow-700"
  defp difficulty_badge("hard"), do: "bg-red-100 text-red-700"
  defp difficulty_badge(_), do: "bg-gray-100 text-gray-700"

  defp answer_button_class(selected, option, result, correct_answer, show_explanation) do
    base = "w-full p-4 rounded-lg border-2 text-left transition flex items-center justify-between "

    cond do
      show_explanation && option == correct_answer ->
        base <> "border-green-500 bg-green-50"

      show_explanation && option == selected && option != correct_answer ->
        base <> "border-red-500 bg-red-50"

      show_explanation ->
        base <> "border-gray-200 bg-gray-50 opacity-50"

      selected == option ->
        base <> "border-indigo-500 bg-indigo-50"

      true ->
        base <> "border-gray-200 hover:border-indigo-300 hover:bg-indigo-50"
    end
  end

  defp answer_circle_class(selected, option, _result, correct_answer, show_explanation) do
    cond do
      show_explanation && option == correct_answer ->
        "bg-green-500 text-white"

      show_explanation && option == selected && option != correct_answer ->
        "bg-red-500 text-white"

      show_explanation ->
        "bg-gray-200 text-gray-500"

      selected == option ->
        "bg-indigo-500 text-white"

      true ->
        "bg-gray-200 text-gray-700"
    end
  end
end
