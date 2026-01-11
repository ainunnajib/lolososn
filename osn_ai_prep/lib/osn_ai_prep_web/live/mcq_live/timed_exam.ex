defmodule OsnAiPrepWeb.McqLive.TimedExam do
  use OsnAiPrepWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Timed Exam")
     |> put_flash(:info, "Timed exam feature coming soon!")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="bg-white rounded-lg shadow-lg p-8 text-center">
        <div class="flex justify-center mb-6">
          <div class="bg-purple-100 rounded-full p-4">
            <svg class="h-12 w-12 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>

        <h1 class="text-3xl font-bold text-gray-900 mb-4">Timed Exam Mode</h1>
        <p class="text-lg text-gray-600 mb-6">
          Simulate the NOAI Preliminary round with 300 MCQ questions in 3 hours.
        </p>

        <div class="bg-gray-50 rounded-lg p-6 mb-8">
          <h2 class="font-semibold text-gray-900 mb-4">Coming Soon Features:</h2>
          <ul class="text-left text-gray-600 space-y-2 max-w-md mx-auto">
            <li class="flex items-center">
              <svg class="h-5 w-5 text-purple-500 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              3-hour countdown timer
            </li>
            <li class="flex items-center">
              <svg class="h-5 w-5 text-purple-500 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              300 randomized questions
            </li>
            <li class="flex items-center">
              <svg class="h-5 w-5 text-purple-500 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              Question navigation panel
            </li>
            <li class="flex items-center">
              <svg class="h-5 w-5 text-purple-500 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              Mark questions for review
            </li>
            <li class="flex items-center">
              <svg class="h-5 w-5 text-purple-500 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              Detailed performance report
            </li>
          </ul>
        </div>

        <.link navigate={~p"/mcq"} class="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700">
          <svg class="mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Back to MCQ Practice
        </.link>
      </div>
    </div>
    """
  end
end
