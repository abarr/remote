defmodule Remote.Users.UserServer do
  @moduledoc false
  use GenServer

  @update_interval Application.get_env(:remote, :update_interval) || 60_000

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_update(@update_interval)
    {:ok, %{max_number: Enum.random(0..100), timestamp: nil}}
  end

  @impl true
  def handle_info(:update_user_points, state) do
    time = DateTime.utc_now() |> DateTime.to_time()
    state.max_number |> IO.inspect(label: "#{time} - Updating points, current max_number: ")
    schedule_update(@update_interval)
    {:noreply, %{state | max_number: Enum.random(0..100)}}
  end

  # set timer
  defp schedule_update(interval) do
    Process.send_after(self(), :update_user_points, interval)
  end
end
