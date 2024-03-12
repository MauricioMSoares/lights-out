defmodule LightsOutWeb.Stats do
  use LightsOutWeb, :live_view
  import LightsOut.Timer, only: [get_time: 1]

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
