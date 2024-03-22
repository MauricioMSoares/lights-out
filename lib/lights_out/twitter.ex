defmodule LightsOut.Twitter do
  def post_tweet(message) do
    ExTwitter.configure(Application.get_env(:extwitter, :oauth))
    ExTwitter.update(message)
  end
end
