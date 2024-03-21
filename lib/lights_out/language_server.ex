defmodule LightsOut.LanguageServer do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(default) do
    {:ok, default}
  end

  def set_locale(value) do
    GenServer.cast(__MODULE__, {:set_locale, value})
  end

  def get_settings do
    GenServer.call(__MODULE__, :get_settings)
  end

  def handle_cast({:set_locale, value}, state) do
    {:noreply, Map.put(state, :locale, value)}
  end

  def handle_call(:get_settings, _from, state) do
    {:reply, state, state}
  end
end
