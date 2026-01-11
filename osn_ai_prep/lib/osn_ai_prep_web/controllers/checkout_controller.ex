defmodule OsnAiPrepWeb.CheckoutController do
  use OsnAiPrepWeb, :controller

  alias OsnAiPrep.Subscriptions

  # Stripe Price IDs - these should match your Stripe Dashboard configuration
  # TODO: Move to config/runtime.exs for production
  @price_ids %{
    "monthly" => System.get_env("STRIPE_MONTHLY_PRICE_ID", "price_monthly_placeholder"),
    "yearly" => System.get_env("STRIPE_YEARLY_PRICE_ID", "price_yearly_placeholder"),
    "lifetime" => System.get_env("STRIPE_LIFETIME_PRICE_ID", "price_lifetime_placeholder")
  }

  @doc """
  Redirects the user to Stripe Checkout for the selected plan.
  """
  def create(conn, %{"plan" => plan}) when plan in ["monthly", "yearly", "lifetime"] do
    user = conn.assigns.current_scope.user

    success_url = url(~p"/checkout/success?session_id={CHECKOUT_SESSION_ID}")
    cancel_url = url(~p"/pricing")

    price_id = @price_ids[plan]

    result =
      case plan do
        "lifetime" ->
          Subscriptions.create_lifetime_checkout_session(user, price_id, success_url, cancel_url)

        _ ->
          Subscriptions.create_checkout_session(user, price_id, success_url, cancel_url)
      end

    case result do
      {:ok, session} ->
        redirect(conn, external: session.url)

      {:error, error} ->
        conn
        |> put_flash(:error, "Unable to start checkout: #{inspect(error)}")
        |> redirect(to: ~p"/pricing")
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "Invalid plan selected")
    |> redirect(to: ~p"/pricing")
  end

  @doc """
  Handles successful checkout completion.
  Shows a success message and redirects to dashboard.
  """
  def success(conn, %{"session_id" => _session_id}) do
    # The webhook will handle the actual subscription activation
    # This just shows a success message to the user
    conn
    |> put_flash(:info, "Thank you for subscribing! Your premium access is now active.")
    |> redirect(to: ~p"/dashboard")
  end

  def success(conn, _params) do
    redirect(conn, to: ~p"/dashboard")
  end

  @doc """
  Redirects to Stripe Customer Portal for subscription management.
  """
  def portal(conn, _params) do
    user = conn.assigns.current_scope.user
    return_url = url(~p"/dashboard")

    case Subscriptions.create_portal_session(user, return_url) do
      {:ok, session} ->
        redirect(conn, external: session.url)

      {:error, :no_stripe_customer} ->
        conn
        |> put_flash(:error, "No subscription found. Please subscribe first.")
        |> redirect(to: ~p"/pricing")

      {:error, error} ->
        conn
        |> put_flash(:error, "Unable to open billing portal: #{inspect(error)}")
        |> redirect(to: ~p"/dashboard")
    end
  end
end
