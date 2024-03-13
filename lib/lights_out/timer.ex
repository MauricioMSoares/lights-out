defmodule LightsOut.Timer do
  @minute 60
  @hour @minute * 60

  def get_time(start_datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, start_datetime)

    hours = Integer.floor_div(diff, @hour)
    minutes = Integer.floor_div(rem(diff, @hour), @minute)
    seconds = rem(rem(diff, @hour), @minute)

    cond do
      hours > 0 ->
        "#{hours} #{pluralize("hour", hours)}, #{minutes} min and #{seconds} sec"

      minutes > 0 ->
        "#{minutes} min and #{seconds} sec"

      true ->
        "#{seconds} sec"
    end
  end

  defp pluralize(word, count) do
    if count > 1, do: "#{word}s", else: word
  end
end
