defmodule OsnAiPrep.Subscriptions do
  @moduledoc """
  The Subscriptions context handles Stripe integration and subscription management.
  """

  import Ecto.Query, warn: false
  alias OsnAiPrep.Repo
  alias OsnAiPrep.Accounts.User

  @doc """
  Gets a user by their Stripe customer ID.
  """
  def get_user_by_stripe_customer_id(customer_id) do
    Repo.get_by(User, stripe_customer_id: customer_id)
  end

  @doc """
  Creates or retrieves a Stripe customer for a user.
  """
  def get_or_create_stripe_customer(%User{} = user) do
    if user.stripe_customer_id do
      {:ok, user.stripe_customer_id}
    else
      case Stripe.Customer.create(%{email: user.email, metadata: %{user_id: user.id}}) do
        {:ok, customer} ->
          {:ok, _updated_user} = update_stripe_customer_id(user, customer.id)
          {:ok, customer.id}

        {:error, error} ->
          {:error, error}
      end
    end
  end

  @doc """
  Updates the user's Stripe customer ID.
  """
  def update_stripe_customer_id(%User{} = user, customer_id) do
    user
    |> Ecto.Changeset.change(stripe_customer_id: customer_id)
    |> Repo.update()
  end

  @doc """
  Creates a Stripe Checkout session for subscription.
  """
  def create_checkout_session(%User{} = user, price_id, success_url, cancel_url) do
    with {:ok, customer_id} <- get_or_create_stripe_customer(user) do
      Stripe.Checkout.Session.create(%{
        customer: customer_id,
        mode: "subscription",
        line_items: [
          %{
            price: price_id,
            quantity: 1
          }
        ],
        success_url: success_url,
        cancel_url: cancel_url,
        metadata: %{user_id: user.id}
      })
    end
  end

  @doc """
  Creates a Stripe Checkout session for one-time payment (lifetime).
  """
  def create_lifetime_checkout_session(%User{} = user, price_id, success_url, cancel_url) do
    with {:ok, customer_id} <- get_or_create_stripe_customer(user) do
      Stripe.Checkout.Session.create(%{
        customer: customer_id,
        mode: "payment",
        line_items: [
          %{
            price: price_id,
            quantity: 1
          }
        ],
        success_url: success_url,
        cancel_url: cancel_url,
        metadata: %{user_id: user.id}
      })
    end
  end

  @doc """
  Creates a Stripe Customer Portal session for managing subscriptions.
  """
  def create_portal_session(%User{} = user, return_url) do
    if user.stripe_customer_id do
      Stripe.BillingPortal.Session.create(%{
        customer: user.stripe_customer_id,
        return_url: return_url
      })
    else
      {:error, :no_stripe_customer}
    end
  end

  @doc """
  Activates a subscription for a user.
  """
  def activate_subscription(customer_id, plan \\ "monthly") do
    case get_user_by_stripe_customer_id(customer_id) do
      nil ->
        {:error, :user_not_found}

      user ->
        user
        |> Ecto.Changeset.change(%{
          subscription_status: "active",
          subscription_plan: plan
        })
        |> Repo.update()
    end
  end

  @doc """
  Activates a lifetime subscription for a user.
  """
  def activate_lifetime_subscription(customer_id) do
    case get_user_by_stripe_customer_id(customer_id) do
      nil ->
        {:error, :user_not_found}

      user ->
        user
        |> Ecto.Changeset.change(%{
          subscription_status: "active",
          subscription_plan: "lifetime",
          subscription_ends_at: nil
        })
        |> Repo.update()
    end
  end

  @doc """
  Cancels a subscription for a user.
  """
  def cancel_subscription(customer_id) do
    case get_user_by_stripe_customer_id(customer_id) do
      nil ->
        {:error, :user_not_found}

      user ->
        user
        |> Ecto.Changeset.change(%{
          subscription_status: "canceled"
        })
        |> Repo.update()
    end
  end

  @doc """
  Marks a subscription as past due.
  """
  def mark_subscription_past_due(customer_id) do
    case get_user_by_stripe_customer_id(customer_id) do
      nil ->
        {:error, :user_not_found}

      user ->
        user
        |> Ecto.Changeset.change(%{
          subscription_status: "past_due"
        })
        |> Repo.update()
    end
  end

  @doc """
  Updates the subscription end date.
  """
  def update_subscription_end_date(customer_id, ends_at) do
    case get_user_by_stripe_customer_id(customer_id) do
      nil ->
        {:error, :user_not_found}

      user ->
        user
        |> Ecto.Changeset.change(%{
          subscription_ends_at: ends_at
        })
        |> Repo.update()
    end
  end

  @doc """
  Checks if a user has an active subscription.
  """
  def has_active_subscription?(%User{subscription_status: status}) do
    status == "active"
  end

  def has_active_subscription?(nil), do: false

  @doc """
  Checks if a user has a lifetime subscription.
  """
  def has_lifetime_subscription?(%User{subscription_plan: plan}) do
    plan == "lifetime"
  end

  def has_lifetime_subscription?(nil), do: false

  @doc """
  Gets subscription details for a user.
  """
  def get_subscription_details(%User{} = user) do
    %{
      status: user.subscription_status || "free",
      plan: user.subscription_plan,
      ends_at: user.subscription_ends_at,
      is_active: has_active_subscription?(user),
      is_lifetime: has_lifetime_subscription?(user)
    }
  end
end
