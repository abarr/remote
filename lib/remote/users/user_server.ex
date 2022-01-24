defmodule Remote.Users.UserServer do
  @moduledoc false
  use GenServer

  alias Remote.Users.BuildQuery
  require Logger

  # Default values if none exist in configuration
  @update_interval 60_000
  @max_num_range 100
  @min_num_range 0
  @users_returned_limit 2

  # Initialise Genserver
  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      build_configuration_from_opts(opts),
      name: Access.get(opts, :name, __MODULE__)
    )
  end

  #  GenServer starts with deafult state:
  @impl true
  def init(config) do
    schedule_update(config.update_interval)
    {:ok, %{values: %{max_number: Enum.random(0..100), timestamp: nil}, config: config}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_users_points_greater_than_max, _from, state) do
    users = BuildQuery.list_users_by(state.values.max_number, state.config.users_returned_limit)
    result = {:ok, %{users: users, timestamp: state.values.timestamp}}
    state = put_in(state.values[:timestamp], DateTime.utc_now())
    {:reply, result, state}
  end

  #  Based on the update_interval the server will update the points asynchronously
  @impl true
  def handle_info(:update_user_points, state) do
    Task.async(fn ->
      BuildQuery.update_all_users_points(state.config.max_num_range, state.config.min_num_range)
    end)
    schedule_update(state.config.update_interval)
    {:noreply, state}
  end

  # monitor for task completion
  def handle_info({ref, :ok}, state) do
    # Remove monitoring for normal :DOWN msg
    Process.demonitor(ref, [:flush])
    # Log results
    IO.puts "Update completed successfully"
    {:noreply, state}
  end

  # Catch a task failure and handle restart 
  def handle_info({:DOWN, _ref, _, _, reason}, state) do
    IO.puts "Users points update failed with reason #{inspect(reason)}"
    # Raise and recover using some defined process
    {:noreply, state}
  end

  # set timer
  defp schedule_update(interval) do
    Process.send_after(self(), :update_user_points, interval)
  end

  # create the config to be stored in state
  defp build_configuration_from_opts(opts) do
    required_config = [:update_interval, :max_num_range, :min_num_range, :users_returned_limit]

    Enum.reduce(required_config, %{}, fn attr, acc ->
      Map.put(acc, attr, Access.get(opts, attr, get_default(attr)))
    end)
  end

  defp get_default(:update_interval),
    do: Application.get_env(:remote, :update_interval) || @update_interval

  defp get_default(:max_num_range),
    do: Application.get_env(:remote, :max_num_range) || @max_num_range

  defp get_default(:min_num_range),
    do: Application.get_env(:remote, :min_num_range) || @min_num_range

  defp get_default(:users_returned_limit),
    do: Application.get_env(:remote, :users_returned_limit) || @users_returned_limit
end
