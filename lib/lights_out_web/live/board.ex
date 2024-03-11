defmodule LightsOutWeb.Board do
  use LightsOutWeb, :live_view

  def mount(_params, _session, socket) do
    grid = for x <- 0..4, y <- 0..4, into: %{}, do: {{x, y}, false}

    {:ok, assign(socket, grid: grid)}
  end

  def handle_event("toggle", %{"x" => x, "y" => y}, socket) do
    grid = socket.assigns.grid
    grid_x = x |> String.to_integer()
    grid_y = y |> String.to_integer()

    updated_grid =
      grid
      |> Map.put(
        {grid_x, grid_y},
        !grid[{grid_x, grid_y}]
      )

    {:noreply, assign(socket, :grid, updated_grid)}
  end
end
