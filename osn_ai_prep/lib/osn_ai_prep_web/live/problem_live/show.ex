defmodule OsnAiPrepWeb.ProblemLive.Show do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Problems

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    problem = Problems.get_problem!(id)
    current_user = socket.assigns[:current_scope] && socket.assigns.current_scope.user

    is_solved =
      if current_user do
        Problems.user_solved_problem?(current_user.id, problem.id)
      else
        false
      end

    {:ok,
     socket
     |> assign(:page_title, problem.title_en)
     |> assign(:problem, problem)
     |> assign(:current_user, current_user)
     |> assign(:is_solved, is_solved)}
  end

  @impl true
  def handle_event("mark_solved", _params, socket) do
    user = socket.assigns.current_user
    problem = socket.assigns.problem

    case Problems.mark_problem_solved(user.id, problem.id) do
      {:ok, _submission} ->
        # Broadcast to leaderboard subscribers
        Phoenix.PubSub.broadcast(OsnAiPrep.PubSub, "leaderboard", {:leaderboard_updated})

        {:noreply,
         socket
         |> assign(:is_solved, true)
         |> put_flash(:info, "Problem marked as solved!")}

      {:error, :already_solved} ->
        {:noreply,
         socket
         |> assign(:is_solved, true)
         |> put_flash(:info, "You've already solved this problem!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not mark problem as solved.")}
    end
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
      "noai_prelim" -> "NOAI Preliminary"
      "noai_final" -> "NOAI Final"
      "osn_ai" -> "OSN AI / Pelatnas"
      "ioai" -> "IOAI"
      _ -> competition
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Back button -->
      <div class="mb-6">
        <.link navigate={~p"/problems"} class="inline-flex items-center text-sm font-medium text-indigo-600 hover:text-indigo-500">
          <svg class="mr-2 h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
          </svg>
          Back to Problems
        </.link>
      </div>

      <!-- Problem Card -->
      <div class="bg-white shadow rounded-lg overflow-hidden">
        <div class="p-6 sm:p-8">
          <!-- Header -->
          <div class="mb-6">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2 mb-3">
                <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{difficulty_badge_class(@problem.difficulty)}"}>
                  <%= String.capitalize(@problem.difficulty || "unknown") %>
                </span>
                <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{competition_badge_class(@problem.competition)}"}>
                  <%= competition_label(@problem.competition) %>
                </span>
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                  <%= @problem.topic %>
                </span>
              </div>
              <%= if @is_solved do %>
                <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                  <svg class="mr-1.5 h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                  Solved
                </span>
              <% end %>
            </div>
            <h1 class="text-2xl font-bold text-gray-900"><%= @problem.title_en %></h1>
            <p class="mt-1 text-sm text-gray-500"><%= @problem.title_id %></p>
          </div>

          <!-- Description -->
          <div class="mb-8">
            <h2 class="text-lg font-medium text-gray-900 mb-3">Problem Description</h2>
            <div class="prose prose-sm max-w-none">
              <div class="bg-gray-50 rounded-lg p-4 mb-4">
                <h3 class="text-sm font-medium text-gray-700 mb-2">English</h3>
                <p class="text-gray-900 whitespace-pre-wrap"><%= @problem.description_en %></p>
              </div>
              <div class="bg-gray-50 rounded-lg p-4">
                <h3 class="text-sm font-medium text-gray-700 mb-2">Bahasa Indonesia</h3>
                <p class="text-gray-900 whitespace-pre-wrap"><%= @problem.description_id %></p>
              </div>
            </div>
          </div>

          <!-- Actions -->
          <div class="border-t border-gray-200 pt-6">
            <div class="flex flex-wrap gap-4">
              <!-- Open in Colab Button -->
              <%= if @problem.colab_url do %>
                <a
                  href={@problem.colab_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  <svg class="mr-2 h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 0C5.372 0 0 5.372 0 12s5.372 12 12 12 12-5.372 12-12S18.628 0 12 0zm0 2c5.523 0 10 4.477 10 10s-4.477 10-10 10S2 17.523 2 12 6.477 2 12 2zm-1 5v4H7v2h4v4h2v-4h4v-2h-4V7h-2z"/>
                  </svg>
                  Open in Google Colab
                  <svg class="ml-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                  </svg>
                </a>
              <% end %>

              <!-- Mark as Solved Button -->
              <%= if @current_user do %>
                <%= if @is_solved do %>
                  <button
                    disabled
                    class="inline-flex items-center px-6 py-3 border border-green-300 text-base font-medium rounded-md text-green-700 bg-green-50 cursor-not-allowed"
                  >
                    <svg class="mr-2 h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                    </svg>
                    Already Solved
                  </button>
                <% else %>
                  <button
                    phx-click="mark_solved"
                    class="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                  >
                    <svg class="mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    Mark as Solved
                  </button>
                <% end %>
              <% else %>
                <.link navigate={~p"/users/log-in"} class="inline-flex items-center px-6 py-3 border border-gray-300 text-base font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                  <svg class="mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
                  </svg>
                  Log in to track progress
                </.link>
              <% end %>
            </div>

            <%= if @problem.colab_url do %>
              <p class="mt-4 text-sm text-gray-500">
                Click "Open in Google Colab" to code your solution, then "Mark as Solved" when you're done.
              </p>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
