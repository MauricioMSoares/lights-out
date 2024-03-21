defmodule LightsOut.Timer do
  alias LightsOut.Translations

  @minute 60
  @hour @minute * 60

  def get_time(start_datetime, locale) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, start_datetime)

    hours = Integer.floor_div(diff, @hour)
    minutes = Integer.floor_div(rem(diff, @hour), @minute)
    seconds = rem(rem(diff, @hour), @minute)

    cond do
      hours > 0 ->
        if locale != "ja" do
          "#{hours} #{pluralize(Translations.get_translation(locale, "hour"), hours)}, #{minutes} #{Translations.get_translation(locale, "min")} #{seconds} #{Translations.get_translation(locale, "sec")}"
        else
          "#{hours} #{Translations.get_translation(locale, "hour")} #{minutes} #{Translations.get_translation(locale, "min")} #{seconds} #{Translations.get_translation(locale, "sec")}"
        end

      minutes > 0 ->
        "#{minutes} #{Translations.get_translation(locale, "min")} #{seconds} #{Translations.get_translation(locale, "sec")}"

      true ->
        "#{seconds} #{Translations.get_translation(locale, "sec")}"
    end
  end

  defp pluralize(word, count) do
    if count > 1, do: "#{word}s", else: word
  end
end
