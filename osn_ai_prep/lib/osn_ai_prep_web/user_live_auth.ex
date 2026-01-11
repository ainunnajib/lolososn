defmodule OsnAiPrepWeb.UserLiveAuth do
  @moduledoc """
  LiveView on_mount hook for authentication.

  This module provides `current_scope` to all LiveViews by fetching
  the user from the session token.
  """

  import Phoenix.Component, only: [assign: 3]

  alias OsnAiPrep.Accounts
  alias OsnAiPrep.Accounts.Scope

  @doc """
  Mount hook that assigns current_scope to the socket.

  This should be used in all LiveViews that need access to the current user.
  For public pages, it will assign a nil user scope if not logged in.
  """
  def on_mount(:default, _params, session, socket) do
    socket = assign_current_scope(socket, session)
    {:cont, socket}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = assign_current_scope(socket, session)

    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: "/users/log-in")}
    end
  end

  defp assign_current_scope(socket, session) do
    case session["user_token"] do
      nil ->
        assign(socket, :current_scope, Scope.for_user(nil))

      token ->
        case Accounts.get_user_by_session_token(token) do
          {user, _token_inserted_at} ->
            assign(socket, :current_scope, Scope.for_user(user))

          nil ->
            assign(socket, :current_scope, Scope.for_user(nil))
        end
    end
  end
end
