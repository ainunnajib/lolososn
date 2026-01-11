defmodule OsnAiPrepWeb.DashboardLive do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Problems

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign_stats(user)}
  end

  defp assign_stats(socket, user) do
    total_problems = Problems.count_problems()
    problems_solved = Problems.count_user_submissions(user.id)
    recent_submissions = Problems.list_recent_user_submissions(user.id, 5)
    progress_by_topic = Problems.get_user_progress_by_topic(user.id)
    progress_by_difficulty = Problems.get_user_progress_by_difficulty(user.id)
    user_rank = Problems.get_user_rank(user.id)

    socket
    |> assign(:total_problems, total_problems)
    |> assign(:problems_solved, problems_solved)
    |> assign(:recent_submissions, recent_submissions)
    |> assign(:progress_by_topic, progress_by_topic)
    |> assign(:progress_by_difficulty, progress_by_difficulty)
    |> assign(:user_rank, user_rank)
    |> assign(:completion_percentage, safe_percentage(problems_solved, total_problems))
  end

  defp safe_percentage(_solved, 0), do: 0
  defp safe_percentage(solved, total), do: round(solved / total * 100)

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

  defp difficulty_color(difficulty) do
    case difficulty do
      "easy" -> "bg-green-500"
      "medium" -> "bg-yellow-500"
      "hard" -> "bg-red-500"
      _ -> "bg-gray-500"
    end
  end

  defp format_date(nil), do: "Never"
  defp format_date(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p class="mt-2 text-gray-600">Track your AI Olympiad preparation progress</p>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <!-- Problems Solved -->
        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="flex-shrink-0 bg-indigo-500 rounded-md p-3">
              <svg class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Problems Solved</p>
              <p class="text-2xl font-semibold text-gray-900"><%= @problems_solved %> / <%= @total_problems %></p>
            </div>
          </div>
        </div>

        <!-- Completion Rate -->
        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="flex-shrink-0 bg-green-500 rounded-md p-3">
              <svg class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Completion Rate</p>
              <p class="text-2xl font-semibold text-gray-900"><%= @completion_percentage %>%</p>
            </div>
          </div>
        </div>

        <!-- Rank -->
        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="flex-shrink-0 bg-yellow-500 rounded-md p-3">
              <svg class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Your Rank</p>
              <p class="text-2xl font-semibold text-gray-900">
                <%= if @user_rank, do: "##{@user_rank.rank}", else: "Unranked" %>
              </p>
            </div>
          </div>
        </div>

        <!-- View Leaderboard -->
        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center justify-between h-full">
            <div>
              <p class="text-sm font-medium text-gray-500">Leaderboard</p>
              <p class="text-lg font-semibold text-gray-900">See rankings</p>
            </div>
            <.link navigate={~p"/leaderboard"} class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200">
              View
              <svg class="ml-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </.link>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Progress by Topic -->
        <div class="bg-white rounded-lg shadow p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">Progress by Topic</h2>
          <%= if map_size(@progress_by_topic) == 0 do %>
            <p class="text-gray-500 text-center py-8">No problems available yet</p>
          <% else %>
            <div class="space-y-4">
              <%= for {topic, progress} <- Enum.sort_by(@progress_by_topic, fn {_, p} -> -p.percentage end) do %>
                <div>
                  <div class="flex justify-between text-sm mb-1">
                    <span class="font-medium text-gray-700"><%= topic_label(topic) %></span>
                    <span class="text-gray-500"><%= progress.solved %>/<%= progress.total %></span>
                  </div>
                  <div class="w-full bg-gray-200 rounded-full h-2.5">
                    <div class="bg-indigo-600 h-2.5 rounded-full" style={"width: #{progress.percentage}%"}></div>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>

        <!-- Progress by Difficulty -->
        <div class="bg-white rounded-lg shadow p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">Progress by Difficulty</h2>
          <%= if map_size(@progress_by_difficulty) == 0 do %>
            <p class="text-gray-500 text-center py-8">No problems available yet</p>
          <% else %>
            <div class="space-y-4">
              <%= for difficulty <- ["easy", "medium", "hard"] do %>
                <%= if progress = @progress_by_difficulty[difficulty] do %>
                  <div>
                    <div class="flex justify-between text-sm mb-1">
                      <span class="font-medium text-gray-700 capitalize"><%= difficulty %></span>
                      <span class="text-gray-500"><%= progress.solved %>/<%= progress.total %></span>
                    </div>
                    <div class="w-full bg-gray-200 rounded-full h-2.5">
                      <div class={"#{difficulty_color(difficulty)} h-2.5 rounded-full"} style={"width: #{progress.percentage}%"}></div>
                    </div>
                  </div>
                <% end %>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="mt-8 bg-white rounded-lg shadow">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-semibold text-gray-900">Recent Activity</h2>
        </div>
        <%= if Enum.empty?(@recent_submissions) do %>
          <div class="p-12 text-center">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">No submissions yet</h3>
            <p class="mt-1 text-sm text-gray-500">Start solving problems to track your progress.</p>
            <div class="mt-6">
              <.link navigate={~p"/problems"} class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700">
                <svg class="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                </svg>
                Browse Problems
              </.link>
            </div>
          </div>
        <% else %>
          <ul class="divide-y divide-gray-200">
            <%= for submission <- @recent_submissions do %>
              <li class="px-6 py-4 hover:bg-gray-50">
                <.link navigate={~p"/problems/#{submission.problem_id}"} class="flex items-center justify-between">
                  <div>
                    <p class="text-sm font-medium text-gray-900"><%= submission.problem.title_en %></p>
                    <p class="text-sm text-gray-500">Solved on <%= format_date(submission.solved_at) %></p>
                  </div>
                  <svg class="h-5 w-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                </.link>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
    </div>
    """
  end
end
