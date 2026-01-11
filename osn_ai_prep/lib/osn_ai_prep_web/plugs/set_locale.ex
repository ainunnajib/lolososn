defmodule OsnAiPrepWeb.Plugs.SetLocale do
  @moduledoc """
  Plug to set the locale for the current request.

  Priority order:
  1. URL parameter (?locale=id)
  2. User's preferred language (if logged in)
  3. Session stored locale
  4. Accept-Language header
  5. Default locale (en)
  """

  import Plug.Conn

  @supported_locales ["en", "id"]
  @default_locale "en"

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = get_locale(conn)
    Gettext.put_locale(OsnAiPrepWeb.Gettext, locale)

    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end

  defp get_locale(conn) do
    # Priority 1: URL parameter
    locale_from_params(conn) ||
      # Priority 2: User preference (if logged in)
      locale_from_user(conn) ||
      # Priority 3: Session
      locale_from_session(conn) ||
      # Priority 4: Accept-Language header
      locale_from_header(conn) ||
      # Priority 5: Default
      @default_locale
  end

  defp locale_from_params(conn) do
    conn.params["locale"]
    |> validate_locale()
  end

  defp locale_from_user(conn) do
    case conn.assigns do
      %{current_scope: %{user: %{preferred_language: lang}}} when is_binary(lang) ->
        validate_locale(lang)

      _ ->
        nil
    end
  end

  defp locale_from_session(conn) do
    get_session(conn, :locale)
    |> validate_locale()
  end

  defp locale_from_header(conn) do
    conn
    |> get_req_header("accept-language")
    |> List.first()
    |> parse_accept_language()
  end

  defp parse_accept_language(nil), do: nil

  defp parse_accept_language(header) do
    header
    |> String.split(",")
    |> Enum.map(&parse_language_tag/1)
    |> Enum.sort_by(fn {_lang, quality} -> -quality end)
    |> Enum.find_value(fn {lang, _quality} -> validate_locale(lang) end)
  end

  defp parse_language_tag(tag) do
    case String.split(String.trim(tag), ";q=") do
      [lang] -> {normalize_lang(lang), 1.0}
      [lang, quality] -> {normalize_lang(lang), parse_quality(quality)}
    end
  end

  defp normalize_lang(lang) do
    lang
    |> String.downcase()
    |> String.split("-")
    |> List.first()
  end

  defp parse_quality(q) do
    case Float.parse(q) do
      {quality, _} -> quality
      :error -> 0.0
    end
  end

  defp validate_locale(nil), do: nil
  defp validate_locale(locale) when locale in @supported_locales, do: locale
  defp validate_locale(_), do: nil
end
