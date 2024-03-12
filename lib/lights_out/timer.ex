defmodule LightsOut.Timer do
  def get_time(start_datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, start_datetime)
    diff
  end
end
