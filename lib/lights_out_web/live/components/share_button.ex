defmodule LightsOutWeb.ShareButton do
  use LightsOutWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("post_tweet", _params, socket) do
    {:noreply, socket}
  end
end
