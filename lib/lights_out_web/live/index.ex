defmodule LightsOutWeb.Index do
  use LightsOutWeb, :live_view

  def mount(_params, _session, socket) do
    grid = for x <- 0..2, y <- 0..2, into: %{}, do: {{x, y}, false}

    {:ok, assign(socket, grid: grid)}
  end

  def handle_event("start", _params, socket) do
    {:noreply, socket}
  end
end
