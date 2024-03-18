defmodule LightsOut.SoundServer do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(default) do
    {:ok, default}
  end

  def set_sfx(value) do
    GenServer.cast(__MODULE__, {:set_sfx, value})
  end

  def set_music(value) do
    GenServer.cast(__MODULE__, {:set_music, value})
  end

  def get_settings do
    GenServer.call(__MODULE__, :get_settings)
  end

  def handle_cast({:set_sfx, value}, state) do
    {:noreply, Map.put(state, :sfx, value)}
  end

  def handle_cast({:set_music, value}, state) do
    {:noreply, Map.put(state, :music, value)}
  end

  def handle_call(:get_settings, _from, state) do
    {:reply, state, state}
  end
end
