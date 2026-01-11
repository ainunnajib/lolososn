defmodule OsnAiPrepWeb.WebhookController do
  use OsnAiPrepWeb, :controller

  require Logger

  alias OsnAiPrep.Subscriptions

  @doc """
  Handles Stripe webhook events.

  Events handled:
  - checkout.session.completed: User completed checkout
  - customer.subscription.created: Subscription created
  - customer.subscription.updated: Subscription updated (plan change, renewal)
  - customer.subscription.deleted: Subscription canceled
  - invoice.payment_succeeded: Payment successful
  - invoice.payment_failed: Payment failed

  Webhook signature verification should be enabled in production.
  """
  def stripe(conn, params) do
    # In production, verify webhook signature:
    # signature = get_req_header(conn, "stripe-signature") |> List.first()
    # webhook_secret = System.get_env("STRIPE_WEBHOOK_SECRET")
    # Stripe.Webhook.construct_event(raw_body, signature, webhook_secret)

    event_type = params["type"]
    data = params["data"]["object"]

    Logger.info("Received Stripe webhook: #{event_type}")

    case handle_event(event_type, data) do
      :ok ->
        send_resp(conn, 200, "OK")

      {:ok, _result} ->
        send_resp(conn, 200, "OK")

      {:error, reason} ->
        Logger.error("Webhook error for #{event_type}: #{inspect(reason)}")
        send_resp(conn, 400, "Error: #{inspect(reason)}")
    end
  end

  # Checkout completed - activate subscription
  defp handle_event("checkout.session.completed", %{"customer" => customer_id, "mode" => mode} = data) do
    Logger.info("Checkout completed for customer: #{customer_id}, mode: #{mode}")

    case mode do
      "subscription" ->
        # Regular subscription (monthly/yearly)
        Subscriptions.activate_subscription(customer_id, get_plan_from_metadata(data))

      "payment" ->
        # One-time payment (lifetime)
        Subscriptions.activate_lifetime_subscription(customer_id)
    end
  end

  # Subscription created
  defp handle_event("customer.subscription.created", %{"customer" => customer_id} = data) do
    plan = get_plan_from_subscription(data)
    Logger.info("Subscription created for customer: #{customer_id}, plan: #{plan}")
    Subscriptions.activate_subscription(customer_id, plan)
  end

  # Subscription updated (renewal, plan change)
  defp handle_event("customer.subscription.updated", %{"customer" => customer_id, "status" => status} = data) do
    Logger.info("Subscription updated for customer: #{customer_id}, status: #{status}")

    case status do
      "active" ->
        plan = get_plan_from_subscription(data)
        Subscriptions.activate_subscription(customer_id, plan)

      "past_due" ->
        Subscriptions.mark_subscription_past_due(customer_id)

      "canceled" ->
        Subscriptions.cancel_subscription(customer_id)

      _ ->
        :ok
    end
  end

  # Subscription deleted/canceled
  defp handle_event("customer.subscription.deleted", %{"customer" => customer_id}) do
    Logger.info("Subscription deleted for customer: #{customer_id}")
    Subscriptions.cancel_subscription(customer_id)
  end

  # Payment succeeded
  defp handle_event("invoice.payment_succeeded", %{"customer" => customer_id, "subscription" => _sub_id}) do
    Logger.info("Payment succeeded for customer: #{customer_id}")
    # Could update subscription_ends_at here if needed
    :ok
  end

  # Payment failed
  defp handle_event("invoice.payment_failed", %{"customer" => customer_id}) do
    Logger.info("Payment failed for customer: #{customer_id}")
    Subscriptions.mark_subscription_past_due(customer_id)
  end

  # Catch-all for unhandled events
  defp handle_event(event_type, _data) do
    Logger.info("Unhandled Stripe event: #{event_type}")
    :ok
  end

  # Helper to extract plan from checkout session metadata
  defp get_plan_from_metadata(%{"metadata" => %{"plan" => plan}}) when is_binary(plan), do: plan
  defp get_plan_from_metadata(_), do: "monthly"

  # Helper to extract plan from subscription interval
  defp get_plan_from_subscription(%{"items" => %{"data" => [%{"price" => %{"recurring" => %{"interval" => interval}}} | _]}}) do
    case interval do
      "month" -> "monthly"
      "year" -> "yearly"
      _ -> "monthly"
    end
  end
  defp get_plan_from_subscription(_), do: "monthly"
end
