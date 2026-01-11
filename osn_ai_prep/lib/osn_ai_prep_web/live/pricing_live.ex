defmodule OsnAiPrepWeb.PricingLive do
  use OsnAiPrepWeb, :live_view

  alias OsnAiPrep.Subscriptions.Paywall

  @impl true
  def mount(_params, _session, socket) do
    user = get_user(socket)
    feature_access = if user, do: Paywall.feature_access(user), else: Paywall.feature_access(nil)

    {:ok,
     socket
     |> assign(:page_title, "Pricing")
     |> assign(:current_user, user)
     |> assign(:feature_access, feature_access)
     |> assign(:is_premium, user && Paywall.has_premium?(user))}
  end

  defp get_user(socket) do
    case socket.assigns do
      %{current_scope: %{user: user}} -> user
      _ -> nil
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-gray-50 min-h-screen">
      <!-- Hero Section -->
      <div class="bg-indigo-700 py-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 class="text-4xl font-extrabold text-white sm:text-5xl">
            Choose Your Plan
          </h1>
          <p class="mt-4 text-xl text-indigo-200">
            Unlock your full potential for AI Olympiad success
          </p>
        </div>
      </div>

      <!-- Pricing Cards -->
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 -mt-12">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <!-- Free Plan -->
          <div class="bg-white rounded-2xl shadow-lg p-8">
            <h3 class="text-xl font-semibold text-gray-900">Free</h3>
            <p class="mt-2 text-gray-600">Try before you commit</p>
            <div class="mt-6">
              <span class="text-4xl font-bold text-gray-900">$0</span>
              <span class="text-gray-500">/forever</span>
            </div>
            <ul class="mt-8 space-y-4">
              <li class="flex items-center">
                <.icon_check />
                <span class="ml-3 text-gray-600">3 intro lessons per section</span>
              </li>
              <li class="flex items-center">
                <.icon_check />
                <span class="ml-3 text-gray-600">5 starter problems</span>
              </li>
              <li class="flex items-center">
                <.icon_check />
                <span class="ml-3 text-gray-600">30 MCQ questions</span>
              </li>
              <li class="flex items-center">
                <.icon_check />
                <span class="ml-3 text-gray-600">1 mini mock exam (30 min)</span>
              </li>
              <li class="flex items-center text-gray-400">
                <.icon_x />
                <span class="ml-3">AI hints</span>
              </li>
              <li class="flex items-center text-gray-400">
                <.icon_x />
                <span class="ml-3">Leaderboard participation</span>
              </li>
              <li class="flex items-center text-gray-400">
                <.icon_x />
                <span class="ml-3">Completion certificate</span>
              </li>
            </ul>
            <div class="mt-8">
              <%= if @current_user do %>
                <button disabled class="w-full py-3 px-4 rounded-lg border-2 border-gray-300 text-gray-500 font-medium cursor-not-allowed">
                  Current Plan
                </button>
              <% else %>
                <.link navigate={~p"/users/register"} class="block w-full py-3 px-4 rounded-lg border-2 border-indigo-600 text-center text-indigo-600 font-medium hover:bg-indigo-50 transition">
                  Get Started
                </.link>
              <% end %>
            </div>
          </div>

          <!-- Monthly Plan (Highlighted) -->
          <div class="bg-white rounded-2xl shadow-xl p-8 border-2 border-indigo-600 relative">
            <div class="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
              <span class="bg-indigo-600 text-white px-4 py-1 rounded-full text-sm font-medium">
                Most Popular
              </span>
            </div>
            <h3 class="text-xl font-semibold text-gray-900">Monthly</h3>
            <p class="mt-2 text-gray-600">Best for short-term prep</p>
            <div class="mt-6">
              <span class="text-4xl font-bold text-gray-900">$9.99</span>
              <span class="text-gray-500">/month</span>
            </div>
            <ul class="mt-8 space-y-4">
              <li class="flex items-center">
                <.icon_check class="text-indigo-600" />
                <span class="ml-3 text-gray-600">All lessons unlocked</span>
              </li>
              <li class="flex items-center">
                <.icon_check class="text-indigo-600" />
                <span class="ml-3 text-gray-600">50+ problems</span>
              </li>
              <li class="flex items-center">
                <.icon_check class="text-indigo-600" />
                <span class="ml-3 text-gray-600">500+ MCQ questions</span>
              </li>
              <li class="flex items-center">
                <.icon_check class="text-indigo-600" />
                <span class="ml-3 text-gray-600">Full mock exams (3+ hours)</span>
              </li>
              <li class="flex items-center">
                <.icon_check class="text-indigo-600" />
                <span class="ml-3 text-gray-600">Unlimited AI hints</span>
              </li>
              <li class="flex items-center">
                <.icon_check class="text-indigo-600" />
                <span class="ml-3 text-gray-600">Leaderboard participation</span>
              </li>
              <li class="flex items-center">
                <.icon_check class="text-indigo-600" />
                <span class="ml-3 text-gray-600">Completion certificate</span>
              </li>
            </ul>
            <div class="mt-8">
              <%= if @is_premium do %>
                <button disabled class="w-full py-3 px-4 rounded-lg bg-gray-100 text-gray-500 font-medium cursor-not-allowed">
                  Already Subscribed
                </button>
              <% else %>
                <.link href={~p"/checkout/monthly"} class="block w-full py-3 px-4 rounded-lg bg-indigo-600 text-center text-white font-medium hover:bg-indigo-700 transition">
                  Subscribe Now
                </.link>
              <% end %>
            </div>
          </div>

          <!-- Yearly Plan -->
          <div class="bg-white rounded-2xl shadow-lg p-8">
            <h3 class="text-xl font-semibold text-gray-900">Yearly</h3>
            <p class="mt-2 text-gray-600">Best value - save 40%</p>
            <div class="mt-6">
              <span class="text-4xl font-bold text-gray-900">$79</span>
              <span class="text-gray-500">/year</span>
              <p class="text-sm text-green-600 font-medium mt-1">~$6.60/month</p>
            </div>
            <ul class="mt-8 space-y-4">
              <li class="flex items-center">
                <.icon_check class="text-green-600" />
                <span class="ml-3 text-gray-600">Everything in Monthly</span>
              </li>
              <li class="flex items-center">
                <.icon_check class="text-green-600" />
                <span class="ml-3 text-gray-600">Priority support</span>
              </li>
              <li class="flex items-center">
                <.icon_check class="text-green-600" />
                <span class="ml-3 text-gray-600">Early access to new content</span>
              </li>
            </ul>
            <div class="mt-8">
              <%= if @is_premium do %>
                <button disabled class="w-full py-3 px-4 rounded-lg bg-gray-100 text-gray-500 font-medium cursor-not-allowed">
                  Already Subscribed
                </button>
              <% else %>
                <.link href={~p"/checkout/yearly"} class="block w-full py-3 px-4 rounded-lg border-2 border-indigo-600 text-center text-indigo-600 font-medium hover:bg-indigo-50 transition">
                  Subscribe Now
                </.link>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Lifetime Plan Banner -->
        <div class="mt-12 bg-gradient-to-r from-indigo-600 to-purple-600 rounded-2xl shadow-lg p-8 text-white">
          <div class="flex flex-col md:flex-row items-center justify-between">
            <div>
              <h3 class="text-2xl font-bold">Lifetime Access</h3>
              <p class="mt-2 text-indigo-200">One-time payment, access forever. Perfect for serious competitors.</p>
            </div>
            <div class="mt-4 md:mt-0 flex items-center">
              <span class="text-4xl font-bold">$149</span>
              <span class="ml-2 text-indigo-200">one-time</span>
              <%= if @is_premium do %>
                <button disabled class="ml-6 py-3 px-6 rounded-lg bg-white/20 text-white font-medium cursor-not-allowed">
                  Already Subscribed
                </button>
              <% else %>
                <.link href={~p"/checkout/lifetime"} class="ml-6 py-3 px-6 rounded-lg bg-white text-indigo-600 font-medium hover:bg-gray-100 transition">
                  Get Lifetime Access
                </.link>
              <% end %>
            </div>
          </div>
        </div>
      </div>

      <!-- Feature Comparison Table -->
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <h2 class="text-2xl font-bold text-gray-900 text-center mb-8">Feature Comparison</h2>
        <div class="bg-white rounded-2xl shadow-lg overflow-hidden">
          <table class="w-full">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-4 text-left text-sm font-semibold text-gray-900">Feature</th>
                <th class="px-6 py-4 text-center text-sm font-semibold text-gray-900">Free</th>
                <th class="px-6 py-4 text-center text-sm font-semibold text-indigo-600">Premium</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr>
                <td class="px-6 py-4 text-sm text-gray-900">Lessons</td>
                <td class="px-6 py-4 text-center text-sm text-gray-600">3 intro lessons</td>
                <td class="px-6 py-4 text-center text-sm text-gray-900 font-medium">All lessons</td>
              </tr>
              <tr>
                <td class="px-6 py-4 text-sm text-gray-900">Problems</td>
                <td class="px-6 py-4 text-center text-sm text-gray-600">5 problems</td>
                <td class="px-6 py-4 text-center text-sm text-gray-900 font-medium">50+ problems</td>
              </tr>
              <tr>
                <td class="px-6 py-4 text-sm text-gray-900">MCQ Questions</td>
                <td class="px-6 py-4 text-center text-sm text-gray-600">30 questions</td>
                <td class="px-6 py-4 text-center text-sm text-gray-900 font-medium">500+ questions</td>
              </tr>
              <tr>
                <td class="px-6 py-4 text-sm text-gray-900">Mock Exams</td>
                <td class="px-6 py-4 text-center text-sm text-gray-600">1 mini (30 min)</td>
                <td class="px-6 py-4 text-center text-sm text-gray-900 font-medium">Unlimited (3+ hours)</td>
              </tr>
              <tr>
                <td class="px-6 py-4 text-sm text-gray-900">AI Hints</td>
                <td class="px-6 py-4 text-center">
                  <.icon_x class="mx-auto text-gray-400" />
                </td>
                <td class="px-6 py-4 text-center">
                  <.icon_check class="mx-auto text-green-600" />
                </td>
              </tr>
              <tr>
                <td class="px-6 py-4 text-sm text-gray-900">Leaderboard</td>
                <td class="px-6 py-4 text-center text-sm text-gray-600">View only</td>
                <td class="px-6 py-4 text-center text-sm text-gray-900 font-medium">Participate & rank</td>
              </tr>
              <tr>
                <td class="px-6 py-4 text-sm text-gray-900">Certificate</td>
                <td class="px-6 py-4 text-center">
                  <.icon_x class="mx-auto text-gray-400" />
                </td>
                <td class="px-6 py-4 text-center">
                  <.icon_check class="mx-auto text-green-600" />
                </td>
              </tr>
              <tr>
                <td class="px-6 py-4 text-sm text-gray-900">Colab Notebooks</td>
                <td class="px-6 py-4 text-center text-sm text-gray-600">Basic templates</td>
                <td class="px-6 py-4 text-center text-sm text-gray-900 font-medium">All notebooks</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- FAQ Section -->
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <h2 class="text-2xl font-bold text-gray-900 text-center mb-8">Frequently Asked Questions</h2>
        <div class="space-y-4">
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="font-semibold text-gray-900">Can I cancel anytime?</h3>
            <p class="mt-2 text-gray-600">Yes! You can cancel your subscription at any time. You'll retain access until the end of your billing period.</p>
          </div>
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="font-semibold text-gray-900">What payment methods do you accept?</h3>
            <p class="mt-2 text-gray-600">We accept all major credit cards, debit cards, and some local payment methods through Stripe.</p>
          </div>
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="font-semibold text-gray-900">Is there a refund policy?</h3>
            <p class="mt-2 text-gray-600">We offer a 7-day money-back guarantee if you're not satisfied with your purchase.</p>
          </div>
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="font-semibold text-gray-900">Do you offer student discounts?</h3>
            <p class="mt-2 text-gray-600">Yes! Contact us with your student ID for a special discount code.</p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp icon_check(assigns) do
    assigns = assign_new(assigns, :class, fn -> "text-green-500" end)
    ~H"""
    <svg class={"w-5 h-5 #{@class}"} fill="currentColor" viewBox="0 0 20 20">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
    </svg>
    """
  end

  defp icon_x(assigns) do
    assigns = assign_new(assigns, :class, fn -> "text-gray-400" end)
    ~H"""
    <svg class={"w-5 h-5 #{@class}"} fill="currentColor" viewBox="0 0 20 20">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
    </svg>
    """
  end
end
