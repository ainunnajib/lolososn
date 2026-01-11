defmodule OsnAiPrepWeb.ProblemLive.Index do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Problems

  @topics [
    {"All Topics", nil},
    {"Python Basics", "python_basics"},
    {"ML Basics", "ml_basics"},
    {"Neural Networks", "neural_networks"},
    {"Computer Vision", "computer_vision"},
    {"NLP", "nlp"},
    {"Deep Learning", "deep_learning"},
    {"Transformers", "transformers"},
    {"Optimization", "optimization"}
  ]

  @difficulties [
    {"All Difficulties", nil},
    {"Easy", "easy"},
    {"Medium", "medium"},
    {"Hard", "hard"}
  ]

  @competitions [
    {"All Competitions", nil},
    {"NOAI Preliminary", "noai_prelim"},
    {"NOAI Final", "noai_final"},
    {"OSN AI", "osn_ai"},
    {"IOAI", "ioai"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Problem Bank")
     |> assign(:topics, @topics)
     |> assign(:difficulties, @difficulties)
     |> assign(:competitions, @competitions)
     |> assign(:selected_topic, nil)
     |> assign(:selected_difficulty, nil)
     |> assign(:selected_competition, nil)
     |> assign(:problems, list_problems(%{}))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    topic = params["topic"]
    difficulty = params["difficulty"]
    competition = params["competition"]

    filters = %{
      topic: topic,
      difficulty: difficulty,
      competition: competition
    }

    {:noreply,
     socket
     |> assign(:selected_topic, topic)
     |> assign(:selected_difficulty, difficulty)
     |> assign(:selected_competition, competition)
     |> assign(:problems, list_problems(filters))}
  end

  @impl true
  def handle_event("filter", %{"topic" => topic, "difficulty" => difficulty, "competition" => competition}, socket) do
    params =
      %{}
      |> maybe_put("topic", topic)
      |> maybe_put("difficulty", difficulty)
      |> maybe_put("competition", competition)

    {:noreply, push_patch(socket, to: ~p"/problems?#{params}")}
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp list_problems(filters) do
    Problems.list_problems_with_filters(filters)
  end

  defp difficulty_badge_class(difficulty) do
    case difficulty do
      "easy" -> "bg-green-100 text-green-800"
      "medium" -> "bg-yellow-100 text-yellow-800"
      "hard" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  defp competition_badge_class(competition) do
    case competition do
      "noai_prelim" -> "bg-blue-100 text-blue-800"
      "noai_final" -> "bg-indigo-100 text-indigo-800"
      "osn_ai" -> "bg-purple-100 text-purple-800"
      "ioai" -> "bg-pink-100 text-pink-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  defp competition_label(competition) do
    case competition do
      "noai_prelim" -> "NOAI Prelim"
      "noai_final" -> "NOAI Final"
      "osn_ai" -> "OSN AI"
      "ioai" -> "IOAI"
      _ -> competition
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Problem Bank</h1>
        <p class="mt-2 text-gray-600">Practice problems from various AI Olympiad competitions</p>
      </div>

      <!-- Filters -->
      <div class="bg-white shadow rounded-lg p-6 mb-8">
        <form phx-change="filter" class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Topic</label>
            <select name="topic" class="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">
              <%= for {label, value} <- @topics do %>
                <option value={value || ""} selected={@selected_topic == value}><%= label %></option>
              <% end %>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Difficulty</label>
            <select name="difficulty" class="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">
              <%= for {label, value} <- @difficulties do %>
                <option value={value || ""} selected={@selected_difficulty == value}><%= label %></option>
              <% end %>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Competition</label>
            <select name="competition" class="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">
              <%= for {label, value} <- @competitions do %>
                <option value={value || ""} selected={@selected_competition == value}><%= label %></option>
              <% end %>
            </select>
          </div>
        </form>
      </div>

      <!-- Problem List -->
      <div class="bg-white shadow rounded-lg overflow-hidden">
        <%= if Enum.empty?(@problems) do %>
          <div class="p-12 text-center">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">No problems found</h3>
            <p class="mt-1 text-sm text-gray-500">Try adjusting your filters or check back later.</p>
          </div>
        <% else %>
          <ul class="divide-y divide-gray-200">
            <%= for problem <- @problems do %>
              <li class="hover:bg-gray-50">
                <.link navigate={~p"/problems/#{problem.id}"} class="block p-6">
                  <div class="flex items-center justify-between">
                    <div class="flex-1 min-w-0">
                      <h3 class="text-lg font-medium text-gray-900 truncate"><%= problem.title_en %></h3>
                      <p class="mt-1 text-sm text-gray-500 line-clamp-2"><%= problem.description_en %></p>
                      <div class="mt-2 flex items-center gap-2">
                        <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{difficulty_badge_class(problem.difficulty)}"}>
                          <%= String.capitalize(problem.difficulty || "unknown") %>
                        </span>
                        <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{competition_badge_class(problem.competition)}"}>
                          <%= competition_label(problem.competition) %>
                        </span>
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                          <%= problem.topic %>
                        </span>
                      </div>
                    </div>
                    <div class="ml-4 flex-shrink-0">
                      <svg class="h-5 w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                      </svg>
                    </div>
                  </div>
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
