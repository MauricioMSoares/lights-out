defmodule LightsOutWeb.TranslationsDropdown do
  use LightsOutWeb, :live_component

  alias LightsOut.Translations
  alias LightsOut.LanguageServer

  def mount(socket) do
    languages = Translations.get_translations()
    {:ok, assign(socket, dropdown_visible: false, languages: languages)}
  end

  def handle_event("open_dropdown", _params, socket) do
    {:noreply, assign(socket, dropdown_visible: true)}
  end

  def handle_event("change_language", %{"value" => locale}, socket) do
    LanguageServer.set_language(locale)
    send(self(), {:language_changed, locale})
    {:noreply, assign(socket, locale: locale, dropdown_visible: false)}
  end

  def handle_event("close_dropdown", _params, socket) do
    {:noreply, assign(socket, dropdown_visible: false)}
  end
end
