defmodule LightsOutWeb.Board do
  use LightsOutWeb, :live_view

  def mount(_params, _session, socket) do
    grid = setup_grid()

    {:ok, assign(socket, grid: grid, win: false, clicks: 0)}
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
    socket = assign(socket, grid: updated_grid, win: win, clicks: clicks)

    case win do
      true -> {:noreply, push_event(socket, "victory", %{win: win})}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("restart", _params, socket) do
    {:noreply, assign(socket, grid: setup_grid(), win: false, clicks: 0)}
  end

  defp setup_grid do
    grid = for x <- 0..4, y <- 0..4, into: %{}, do: {{x, y}, false}

    level =
      Enum.reduce(1..:rand.uniform(25), %{}, fn _, acc ->
        {x, y} = {:rand.uniform(4), :rand.uniform(4)}
        Map.put(acc, {x, y}, true)
      end)

    Map.merge(grid, level)
  end

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
end
