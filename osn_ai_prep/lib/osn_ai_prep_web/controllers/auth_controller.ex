defmodule OsnAiPrepWeb.AuthController do
  @moduledoc """
  Handles OAuth authentication via Ueberauth (Google, GitHub).
  """
  use OsnAiPrepWeb, :controller
  plug Ueberauth

  alias OsnAiPrep.Accounts

  @doc """
  Handles the OAuth callback from providers.
  Creates or finds the user and logs them in.
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = extract_user_info(auth)

    case Accounts.find_or_create_oauth_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully signed in with #{auth.provider}!")
        |> OsnAiPrepWeb.UserAuth.log_in_user(user)

      {:error, reason} ->
        conn
        |> put_flash(:error, "Could not sign in: #{reason}")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    message = failure.errors |> Enum.map(& &1.message) |> Enum.join(", ")

    conn
    |> put_flash(:error, "Authentication failed: #{message}")
    |> redirect(to: ~p"/users/log-in")
  end

  defp extract_user_info(%{provider: provider, info: info, credentials: _credentials}) do
    %{
      email: info.email,
      name: info.name || info.nickname || info.email,
      provider: to_string(provider),
      provider_uid: info.email  # Using email as unique identifier
    }
  end
end
