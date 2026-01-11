defmodule OsnAiPrepWeb.PageController do
  use OsnAiPrepWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
