defmodule OsnAiPrepWeb.UserSessionHTML do
  use OsnAiPrepWeb, :html

  embed_templates "user_session_html/*"

  defp local_mail_adapter? do
    Application.get_env(:osn_ai_prep, OsnAiPrep.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
