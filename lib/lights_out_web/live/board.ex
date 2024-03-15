defmodule LightsOutWeb.Board do
  use LightsOutWeb, :live_view

  import LightsOut.Timer, only: [get_time: 1]

  def mount(_params, _session, socket) do
    grid = setup_grid()
    socket = assign_sounds(socket)

    {:ok,
     assign(socket,
       grid: grid,
       win: false,
       clicks: 0,
       bg_sound_timer: nil,
       sfx: true,
       music: true
     )}
  end

  def handle_event("toggle", %{"x" => x, "y" => y}, socket) do
    grid = socket.assigns.grid
    grid_x = x |> String.to_integer()
    grid_y = y |> String.to_integer()

    updated_grid =
      find_adjacent_tiles(grid_x, grid_y)
      |> Enum.reduce(%{}, fn point, acc ->
        Map.put(acc, point, !grid[point])
      end)
      |> then(fn toggled_grid -> Map.merge(grid, toggled_grid) end)

    clicks = socket.assigns.clicks |> increment()
    win = updated_grid |> check_win()

    start_datetime =
      if clicks == 1 do
        DateTime.utc_now()
      else
        socket.assigns.start_datetime
      end

    socket =
      assign(socket, grid: updated_grid, win: win, clicks: clicks, start_datetime: start_datetime)

    if clicks == 1 and socket.assigns.music do
      send(self(), :play_bg_sound)
    end

    case win do
      true ->
        socket = assign(socket, time_spent: get_time(socket.assigns.start_datetime))
        if socket.assigns.music do
          send(self(), :stop_bg_sound)
          send(self(), :play_win)
        end
        socket = push_event(socket, "victory", %{win: win})
        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("restart", _params, socket) do
    if socket.assigns.bg_sound_timer do
      send(self(), :stop_bg_sound)
    end

    {:noreply,
     assign(socket, grid: setup_grid(), win: false, clicks: 0, start_datetime: DateTime.utc_now())}
  end

  def handle_event("navigate", _params, socket) do
    Process.sleep(200)
    {:noreply, push_navigate(socket, to: "/")}
  end

  def handle_event("toggle_sfx", _params, socket) do
    {:noreply, assign(socket, sfx: !socket.assigns.sfx)}
  end

  def handle_event("toggle_music", _params, socket) do
    case socket.assigns.clicks > 0 do
      true ->
        case socket.assigns.music do
          true -> send(self(), :stop_bg_sound)
          false -> send(self(), :play_bg_sound)
        end

      false ->
        {:noreply, socket}
    end

    {:noreply, assign(socket, music: !socket.assigns.music)}
  end

  def handle_info(:play_bg_sound, socket) do
    socket = push_event(socket, "play-sound", %{name: "bg_sfx"})
    {:noreply, start_bg_sound(socket)}
  end

  def handle_info(:stop_bg_sound, socket) do
    socket = push_event(socket, "stop-sound", %{name: "bg_sfx"})
    {:noreply, stop_bg_sound(socket)}
  end

  def handle_info(:play_win, socket) do
    socket = push_event(socket, "play-sound", %{name: "victory_sfx"})
    {:noreply, socket}
  end

  defp setup_grid do
    grid = for x <- 0..4, y <- 0..4, into: %{}, do: {{x, y}, false}

    level =
      Enum.reduce(50..100, grid, fn _, acc ->
        {x, y} = {:rand.uniform(4), :rand.uniform(4)}
        toggle(acc, x, y)
      end)

    level
  end

  defp toggle(grid, x, y) do
    grid
    |> toggle_light({x, y})
    |> toggle_light({x - 1, y})
    |> toggle_light({x + 1, y})
    |> toggle_light({x, y - 1})
    |> toggle_light({x, y + 1})
  end

  defp toggle_light(grid, {x, y}) when x in 0..4 and y in 0..4 do
    Map.update(grid, {x, y}, false, &(!&1))
  end

  defp toggle_light(grid, _), do: grid

  defp find_adjacent_tiles(x, y) do
    prev_x = Kernel.max(0, x - 1)
    next_x = Kernel.min(4, x + 1)

    prev_y = Kernel.max(0, y - 1)
    next_y = Kernel.min(4, y + 1)

    [{x, y}, {prev_x, y}, {next_x, y}, {x, prev_y}, {x, next_y}]
  end

  defp check_win(grid) do
    grid
    |> Map.values()
    |> Enum.all?(fn light -> !light end)
  end

  defp increment(clicks) do
    clicks + 1
  end

  defp start_bg_sound(socket) do
    timer_ref = Process.send_after(self(), :play_bg_sound, 47500)
    assign(socket, bg_sound_timer: timer_ref)
  end

  defp stop_bg_sound(socket) do
    timer_ref = socket.assigns.bg_sound_timer
    Process.cancel_timer(timer_ref)
    assign(socket, bg_sound_timer: nil)
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
