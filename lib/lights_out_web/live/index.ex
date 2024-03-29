defmodule LightsOutWeb.Index do
  use LightsOutWeb, :live_view

  alias LightsOut.SoundServer
  alias LightsOut.LanguageServer

  def mount(_params, _session, socket) do
    language = LanguageServer.get_settings()
    sound = SoundServer.get_settings()
    grid = for x <- 0..2, y <- 0..2, into: %{}, do: {{x, y}, false}
    socket = assign_sounds(socket)

    {:ok, assign(socket, grid: grid, sfx: sound.sfx, music: sound.music, locale: language.locale)}
  end

  def handle_event("start", _params, socket) do
    Process.sleep(200)
    {:noreply, push_redirect(socket, to: "/board")}
  end

  def handle_event("toggle_sfx", _params, socket) do
    SoundServer.set_sfx(!socket.assigns.sfx)
    {:noreply, assign(socket, sfx: !socket.assigns.sfx)}
  end

  def handle_event("toggle_music", _params, socket) do
    SoundServer.set_music(!socket.assigns.music)
    {:noreply, assign(socket, music: !socket.assigns.music)}
  end

  def handle_info({:language_changed, locale}, socket) do
    {:noreply, assign(socket, locale: locale)}
  end

  defp assign_sounds(socket) do
    json =
      Jason.encode!(%{
        menu_sfx: ~p"/audio/menu-click-sfx.mp3",
        light_sfx: ~p"/audio/light-switch-sfx.mp3",
        victory_sfx: ~p"/audio/victory-sfx.mp3",
        bg_sfx: ~p"/audio/bg-sfx.mp3"
      })

    assign(socket, :sounds, json)
  end
end
