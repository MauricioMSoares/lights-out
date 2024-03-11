defmodule LightsOutWeb.Board do
  use LightsOutWeb, :live_view

  def mount(_params, _session, socket) do
    grid = for x <- 0..4, y <- 0..4, into: %{}, do: {{x, y}, false}

    {:ok, assign(socket, grid: grid)}
  end
end
