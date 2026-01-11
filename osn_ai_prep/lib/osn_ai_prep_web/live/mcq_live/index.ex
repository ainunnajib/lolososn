defmodule OsnAiPrepWeb.McqLive.Index do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Mcq
  alias OsnAiPrep.Subscriptions.Paywall

  @impl true
  def mount(_params, _session, socket) do
    user = get_user(socket)
    topics = Mcq.list_topics()
    stats = if user, do: Mcq.get_user_stats(user.id), else: nil
    stats_by_topic = if user, do: Mcq.get_user_stats_by_topic(user.id), else: %{}
    total_questions = Mcq.count_questions()

    # Get MCQ access info
    attempts_count = if user, do: Mcq.count_user_attempts(user.id), else: 0
    mcq_access = Paywall.mcq_access(user, attempts_count)

    {:ok,
     socket
     |> assign(:page_title, "MCQ Practice")
     |> assign(:current_user, user)
     |> assign(:topics, topics)
     |> assign(:stats, stats)
     |> assign(:stats_by_topic, stats_by_topic)
     |> assign(:total_questions, total_questions)
     |> assign(:mcq_access, mcq_access)
     |> assign(:selected_topic, nil)
     |> assign(:selected_difficulty, nil)
     |> assign(:quiz_size, 10)}
  end

  defp get_user(socket) do
    case socket.assigns do
      %{current_scope: %{user: user}} -> user
      _ -> nil
    end
  end

  @impl true
  def handle_event("select_topic", %{"topic" => topic}, socket) do
    {:noreply, assign(socket, :selected_topic, topic)}
  end

  @impl true
  def handle_event("select_difficulty", %{"difficulty" => difficulty}, socket) do
    {:noreply, assign(socket, :selected_difficulty, difficulty)}
  end

  @impl true
  def handle_event("set_quiz_size", %{"size" => size}, socket) do
    {:noreply, assign(socket, :quiz_size, String.to_integer(size))}
  end

  @impl true
  def handle_event("start_quiz", _params, socket) do
    topic = socket.assigns.selected_topic
    difficulty = socket.assigns.selected_difficulty
    size = socket.assigns.quiz_size

    # Build query params
    params =
      %{}
      |> maybe_add_param("topic", topic)
      |> maybe_add_param("difficulty", difficulty)
      |> Map.put("count", size)

    {:noreply, push_navigate(socket, to: ~p"/mcq/quiz?#{params}")}
  end

  defp maybe_add_param(params, _key, nil), do: params
  defp maybe_add_param(params, _key, ""), do: params
  defp maybe_add_param(params, key, value), do: Map.put(params, key, value)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">MCQ Practice</h1>
        <p class="mt-2 text-gray-600">Test your knowledge with multiple choice questions</p>
      </div>

      <!-- Access Status -->
      <%= case @mcq_access do %>
        <% :unlimited -> %>
          <div class="mb-6 bg-green-50 border border-green-200 rounded-lg p-4">
            <div class="flex items-center">
              <svg class="h-5 w-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
              <span class="text-green-800 font-medium">Premium Access: Unlimited MCQ questions</span>
            </div>
          </div>
        <% {:limited, remaining} -> %>
          <div class="mb-6 bg-amber-50 border border-amber-200 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <svg class="h-5 w-5 text-amber-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                </svg>
                <span class="text-amber-800">
                  <span class="font-medium"><%= remaining %> free questions remaining.</span>
                  <%= if remaining == 0 do %>
                    Upgrade to continue practicing.
                  <% end %>
                </span>
              </div>
              <.link navigate={~p"/pricing"} class="text-sm font-medium text-indigo-600 hover:text-indigo-500">
                Upgrade to Premium
              </.link>
            </div>
          </div>
      <% end %>

      <!-- Stats Overview -->
      <%= if @current_user && @stats do %>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div class="bg-white rounded-lg shadow p-6">
            <p class="text-sm font-medium text-gray-500">Total Attempts</p>
            <p class="text-2xl font-semibold text-gray-900"><%= @stats.total_attempts %></p>
          </div>
          <div class="bg-white rounded-lg shadow p-6">
            <p class="text-sm font-medium text-gray-500">Correct Answers</p>
            <p class="text-2xl font-semibold text-green-600"><%= @stats.correct_attempts %></p>
          </div>
          <div class="bg-white rounded-lg shadow p-6">
            <p class="text-sm font-medium text-gray-500">Accuracy</p>
            <p class="text-2xl font-semibold text-indigo-600"><%= @stats.accuracy %>%</p>
          </div>
        </div>
      <% end %>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Quiz Configuration -->
        <div class="lg:col-span-2">
          <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Start a Quiz</h2>

            <!-- Topic Selection -->
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 mb-2">Select Topic (optional)</label>
              <div class="flex flex-wrap gap-2">
                <button
                  phx-click="select_topic"
                  phx-value-topic=""
                  class={"px-4 py-2 rounded-full text-sm font-medium transition #{if @selected_topic == nil, do: "bg-indigo-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200"}"}
                >
                  All Topics
                </button>
                <%= for topic <- @topics do %>
                  <button
                    phx-click="select_topic"
                    phx-value-topic={topic}
                    class={"px-4 py-2 rounded-full text-sm font-medium transition #{if @selected_topic == topic, do: "bg-indigo-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200"}"}
                  >
                    <%= topic_label(topic) %>
                  </button>
                <% end %>
              </div>
            </div>

            <!-- Difficulty Selection -->
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 mb-2">Select Difficulty (optional)</label>
              <div class="flex gap-2">
                <button
                  phx-click="select_difficulty"
                  phx-value-difficulty=""
                  class={"px-4 py-2 rounded-full text-sm font-medium transition #{if @selected_difficulty == nil, do: "bg-indigo-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200"}"}
                >
                  All
                </button>
                <button
                  phx-click="select_difficulty"
                  phx-value-difficulty="easy"
                  class={"px-4 py-2 rounded-full text-sm font-medium transition #{if @selected_difficulty == "easy", do: "bg-green-600 text-white", else: "bg-green-100 text-green-700 hover:bg-green-200"}"}
                >
                  Easy
                </button>
                <button
                  phx-click="select_difficulty"
                  phx-value-difficulty="medium"
                  class={"px-4 py-2 rounded-full text-sm font-medium transition #{if @selected_difficulty == "medium", do: "bg-yellow-600 text-white", else: "bg-yellow-100 text-yellow-700 hover:bg-yellow-200"}"}
                >
                  Medium
                </button>
                <button
                  phx-click="select_difficulty"
                  phx-value-difficulty="hard"
                  class={"px-4 py-2 rounded-full text-sm font-medium transition #{if @selected_difficulty == "hard", do: "bg-red-600 text-white", else: "bg-red-100 text-red-700 hover:bg-red-200"}"}
                >
                  Hard
                </button>
              </div>
            </div>

            <!-- Quiz Size -->
            <div class="mb-6">
              <label class="block text-sm font-medium text-gray-700 mb-2">Number of Questions</label>
              <div class="flex gap-2">
                <%= for size <- [5, 10, 20, 50] do %>
                  <button
                    phx-click="set_quiz_size"
                    phx-value-size={size}
                    class={"px-4 py-2 rounded-lg text-sm font-medium transition #{if @quiz_size == size, do: "bg-indigo-600 text-white", else: "bg-gray-100 text-gray-700 hover:bg-gray-200"}"}
                  >
                    <%= size %>
                  </button>
                <% end %>
              </div>
            </div>

            <!-- Start Button -->
            <%= if @current_user do %>
              <button
                phx-click="start_quiz"
                class="w-full py-3 px-4 rounded-lg bg-indigo-600 text-white font-medium hover:bg-indigo-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                disabled={match?({:limited, 0}, @mcq_access)}
              >
                Start Quiz (<%= @quiz_size %> questions)
              </button>
            <% else %>
              <.link navigate={~p"/users/register"} class="block w-full py-3 px-4 rounded-lg bg-indigo-600 text-center text-white font-medium hover:bg-indigo-700 transition">
                Sign up to start practicing
              </.link>
            <% end %>
          </div>

          <!-- Quick Actions -->
          <div class="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
            <.link navigate={~p"/mcq/timed"} class="bg-white rounded-lg shadow p-6 hover:shadow-md transition group">
              <div class="flex items-center">
                <div class="flex-shrink-0 bg-purple-100 rounded-lg p-3 group-hover:bg-purple-200 transition">
                  <svg class="h-6 w-6 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <div class="ml-4">
                  <h3 class="font-medium text-gray-900">Timed Exam</h3>
                  <p class="text-sm text-gray-500">Simulate NOAI Preliminary (3 hours)</p>
                </div>
              </div>
            </.link>

            <.link navigate={~p"/problems"} class="bg-white rounded-lg shadow p-6 hover:shadow-md transition group">
              <div class="flex items-center">
                <div class="flex-shrink-0 bg-blue-100 rounded-lg p-3 group-hover:bg-blue-200 transition">
                  <svg class="h-6 w-6 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
                  </svg>
                </div>
                <div class="ml-4">
                  <h3 class="font-medium text-gray-900">Coding Problems</h3>
                  <p class="text-sm text-gray-500">Practice implementation skills</p>
                </div>
              </div>
            </.link>
          </div>
        </div>

        <!-- Topic Stats Sidebar -->
        <div class="lg:col-span-1">
          <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Progress by Topic</h2>
            <%= if Enum.empty?(@topics) do %>
              <p class="text-gray-500 text-center py-4">No questions available yet</p>
            <% else %>
              <div class="space-y-4">
                <%= for topic <- @topics do %>
                  <% topic_stats = @stats_by_topic[topic] || %{total: 0, correct: 0, accuracy: 0} %>
                  <% question_count = Mcq.count_questions(%{topic: topic}) %>
                  <div>
                    <div class="flex justify-between text-sm mb-1">
                      <span class="font-medium text-gray-700"><%= topic_label(topic) %></span>
                      <span class="text-gray-500"><%= question_count %> questions</span>
                    </div>
                    <%= if topic_stats.total > 0 do %>
                      <div class="w-full bg-gray-200 rounded-full h-2">
                        <div class="bg-indigo-600 h-2 rounded-full" style={"width: #{topic_stats.accuracy}%"}></div>
                      </div>
                      <p class="text-xs text-gray-500 mt-1">
                        <%= topic_stats.correct %>/<%= topic_stats.total %> correct (<%= topic_stats.accuracy %>%)
                      </p>
                    <% else %>
                      <div class="w-full bg-gray-200 rounded-full h-2">
                        <div class="bg-gray-300 h-2 rounded-full w-0"></div>
                      </div>
                      <p class="text-xs text-gray-500 mt-1">Not attempted</p>
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <!-- Info Card -->
          <div class="mt-6 bg-indigo-50 rounded-lg p-6">
            <h3 class="font-medium text-indigo-900 mb-2">NOAI Preliminary Format</h3>
            <ul class="text-sm text-indigo-700 space-y-1">
              <li>300 MCQ questions</li>
              <li>3 hours time limit</li>
              <li>Covers all AI/ML topics</li>
              <li>Online format (Google Form)</li>
            </ul>
          </div>
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
      "probability" -> "Probability"
      "linear_algebra" -> "Linear Algebra"
      _ -> topic |> to_string() |> String.replace("_", " ") |> String.capitalize()
    end
  end
end
