defmodule LightsOutWeb.ShareButton do
  use LightsOutWeb, :live_component

  alias LightsOut.Twitter

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("post_tweet", _params, socket) do
    Twitter.post_tweet("I just solved the Lights Out puzzle! Can you do it too?")
    {:noreply, socket}
  end
end
