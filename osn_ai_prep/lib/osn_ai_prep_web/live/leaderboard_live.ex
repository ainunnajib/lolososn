defmodule OsnAiPrepWeb.LeaderboardLive do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Problems

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to leaderboard updates for real-time refresh
    if connected?(socket) do
      Phoenix.PubSub.subscribe(OsnAiPrep.PubSub, "leaderboard")
    end

    current_user = socket.assigns[:current_scope] && socket.assigns.current_scope.user

    {:ok,
     socket
     |> assign(:page_title, "Leaderboard")
     |> assign(:current_user_id, current_user && current_user.id)
     |> assign(:leaderboard, Problems.get_leaderboard(100))
     |> assign(:user_rank, current_user && Problems.get_user_rank(current_user.id))}
  end

  @impl true
  def handle_info({:leaderboard_updated}, socket) do
    current_user_id = socket.assigns.current_user_id

    {:noreply,
     socket
     |> assign(:leaderboard, Problems.get_leaderboard(100))
     |> assign(:user_rank, current_user_id && Problems.get_user_rank(current_user_id))}
  end

  defp mask_email(email) do
    case String.split(email, "@") do
      [username, domain] ->
        masked_username =
          if String.length(username) <= 2 do
            String.duplicate("*", String.length(username))
          else
            String.slice(username, 0, 2) <> String.duplicate("*", String.length(username) - 2)
          end
        masked_username <> "@" <> domain
      _ ->
        email
    end
  end

  defp format_date(nil), do: "Never"
  defp format_date(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y")
  end

  defp rank_badge_class(rank) do
    case rank do
      1 -> "bg-yellow-400 text-yellow-900"
      2 -> "bg-gray-300 text-gray-800"
      3 -> "bg-amber-600 text-white"
      _ -> "bg-gray-100 text-gray-700"
    end
  end

  defp rank_icon(rank) do
    case rank do
      1 -> "🥇"
      2 -> "🥈"
      3 -> "🥉"
      _ -> nil
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Leaderboard</h1>
        <p class="mt-2 text-gray-600">Top performers in AI Olympiad preparation</p>
      </div>

      <!-- Current User's Rank Card (if logged in and ranked) -->
      <%= if @user_rank do %>
        <div class="bg-indigo-50 border border-indigo-200 rounded-lg p-6 mb-8">
          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <div class={"flex-shrink-0 w-12 h-12 rounded-full flex items-center justify-center text-lg font-bold #{rank_badge_class(@user_rank.rank)}"}>
                <%= if icon = rank_icon(@user_rank.rank) do %>
                  <span class="text-2xl"><%= icon %></span>
                <% else %>
                  <%= @user_rank.rank %>
                <% end %>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-indigo-600">Your Ranking</p>
                <p class="text-lg font-semibold text-gray-900">Rank #<%= @user_rank.rank %></p>
              </div>
            </div>
            <div class="text-right">
              <p class="text-2xl font-bold text-indigo-600"><%= @user_rank.problems_solved %></p>
              <p class="text-sm text-gray-500">problems solved</p>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Leaderboard Table -->
      <div class="bg-white shadow rounded-lg overflow-hidden">
        <%= if Enum.empty?(@leaderboard) do %>
          <div class="p-12 text-center">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">No rankings yet</h3>
            <p class="mt-1 text-sm text-gray-500">Be the first to solve problems and claim the top spot!</p>
            <div class="mt-6">
              <.link navigate={~p"/problems"} class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700">
                Start Solving Problems
              </.link>
            </div>
          </div>
        <% else %>
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Rank
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th scope="col" class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Problems Solved
                </th>
                <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Last Active
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for entry <- @leaderboard do %>
                <tr class={if @current_user_id == entry.user_id, do: "bg-indigo-50", else: "hover:bg-gray-50"}>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class={"w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold #{rank_badge_class(entry.rank)}"}>
                      <%= if icon = rank_icon(entry.rank) do %>
                        <span class="text-xl"><%= icon %></span>
                      <% else %>
                        <%= entry.rank %>
                      <% end %>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <div class="flex-shrink-0 h-10 w-10 bg-indigo-100 rounded-full flex items-center justify-center">
                        <span class="text-indigo-600 font-medium text-sm">
                          <%= String.upcase(String.slice(entry.email, 0, 2)) %>
                        </span>
                      </div>
                      <div class="ml-4">
                        <div class="text-sm font-medium text-gray-900">
                          <%= mask_email(entry.email) %>
                          <%= if @current_user_id == entry.user_id do %>
                            <span class="ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-indigo-100 text-indigo-800">
                              You
                            </span>
                          <% end %>
                        </div>
                      </div>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-center">
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                      <%= entry.problems_solved %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm text-gray-500">
                    <%= format_date(entry.last_solved_at) %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% end %>
      </div>

      <!-- Back to Dashboard -->
      <%= if @current_user_id do %>
        <div class="mt-8 text-center">
          <.link navigate={~p"/dashboard"} class="inline-flex items-center text-sm font-medium text-indigo-600 hover:text-indigo-500">
            <svg class="mr-2 h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
            Back to Dashboard
          </.link>
        </div>
      <% end %>
    </div>
    """
  end
end
