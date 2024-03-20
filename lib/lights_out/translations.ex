defmodule LightsOut.Translations do
  @moduledoc """
  Module for handling translations.
  """

  @translations_file "translations.json"

  def get_translations do
    @translations_file
    |> File.read!()
    |> Jason.decode!()
  end

  def get_translation(locale, key) do
    translations = get_translations()

    case Map.get(translations, locale) do
      nil -> {:error, :locale_not_found}
      locale_map -> Map.get(locale_map, key, {:error, :translation_not_found})
    end
  end
end
