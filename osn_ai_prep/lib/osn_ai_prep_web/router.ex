defmodule OsnAiPrepWeb.Router do
  use OsnAiPrepWeb, :router

  import OsnAiPrepWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OsnAiPrepWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug OsnAiPrepWeb.Plugs.SetLocale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Stripe webhooks (no CSRF, no auth)
  scope "/webhooks", OsnAiPrepWeb do
    pipe_through :api

    post "/stripe", WebhookController, :stripe
  end

  scope "/", OsnAiPrepWeb do
    pipe_through :browser

    get "/", PageController, :home

    # Problem Bank (public)
    live "/problems", ProblemLive.Index, :index
    live "/problems/:id", ProblemLive.Show, :show

    # Leaderboard (public, but shows extra info if logged in)
    live "/leaderboard", LeaderboardLive, :index

    # Pricing page (public)
    live "/pricing", PricingLive, :index

    # MCQ Practice (public index, requires login for quiz)
    live "/mcq", McqLive.Index, :index

    # Learning Modules (public, but with paywall)
    live "/lessons", LessonLive.Index, :index
    live "/lessons/:id", LessonLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", OsnAiPrepWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:osn_ai_prep, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OsnAiPrepWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  # OAuth routes (Ueberauth)
  scope "/auth", OsnAiPrepWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/", OsnAiPrepWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
  end

  scope "/", OsnAiPrepWeb do
    pipe_through [:browser, :require_authenticated_user]

    # Dashboard (requires login)
    live "/dashboard", DashboardLive, :index

    # Stripe Checkout (requires login)
    get "/checkout/success", CheckoutController, :success
    get "/checkout/:plan", CheckoutController, :create
    get "/billing", CheckoutController, :portal

    # MCQ Quiz (requires login)
    live "/mcq/quiz", McqLive.Quiz, :quiz
    live "/mcq/timed", McqLive.TimedExam, :timed

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email
  end

  scope "/", OsnAiPrepWeb do
    pipe_through [:browser]

    get "/users/log-in", UserSessionController, :new
    get "/users/log-in/:token", UserSessionController, :confirm
    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
