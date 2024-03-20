defmodule LightsOutWeb.TranslationsDropdown do
  use LightsOutWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, dropdown_visible: false)}
  end

  def handle_event("open_dropdown", _params, socket) do
    {:noreply, assign(socket, dropdown_visible: true)}
  end

  def handle_event("change_language", %{"translations_dropdown" => language_code}, socket) do
    send(self(), {:language_changed, language_code})
    {:noreply, assign(socket, selected_language: language_code, dropdown_visible: false)}
  end
  
  def handle_event("close_dropdown", _params, socket) do
    {:noreply, assign(socket, dropdown_visible: false)}
  end
end
