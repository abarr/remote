defmodule Remote.Users.UserServer do
  @moduledoc false
  use GenServer

  alias Remote.Users.BuildQuery
  require Logger

  #  This GenServer starts with the following state:
  #   {
  #     %{
  #       max_number: #Random number bewteen the configurabe values - defaults to 0-100},
  #       timestamp: nil
  #     },
  #     %{
  #       update_interval: he time set for calling schedule_update/1
  #       max_num_range: The max number in the range for generating random numbers
  #       min_num_range: The min number in the range for generating random numbers
  #       users_returned_limit: sets the limit for the number of users to return - defaults to 2
  #     }
  #   }
  #
  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      build_configuration_from_opts(opts),
      name: Access.get(opts, :name, __MODULE__)
    )
  end

  @impl true
  def init(config) do
    schedule_update(config.update_interval)
    {:ok, {%{max_number: Enum.random(0..100), timestamp: nil}, config}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  # Returns a map that includes a list of users (limited to the number held in configuration)
  # and with points greater than :max_number. The result includes the timestamp value set prior to
  # it being updated for each call.
  #
  #  %{
  #    users: [%{id: 1, points: 67}, %{id: 13, points: 95}],
  #    timestamp: ~U[2022-01-11 05:01:00.763516Z]
  #  }
  #
  def handle_call(:get_users_points_greater_than_max, _from, {state, config}) do
    result =
      build_results(
        :users,
        state.timestamp,
        &BuildQuery.list_by_points_greater_than_with_limit/1,
        {state.max_number, config.users_returned_limit}
      )

    {:reply, result, {%{state | timestamp: DateTime.utc_now()}, config}}
  end

  @impl true
  #  Based on the update_interval the server will update the points value for all users to a random integer
  #  between the min and max range defined in the configuration (The second value in the state tuple).
  def handle_info(:update_user_points, {state, config}) do
    case BuildQuery.update_all_users_points(config.max_num_range, config.min_num_range) do
      :ok ->
        Logger.info("User rows updated with new random points value")
        schedule_update(config.update_interval)
        {:noreply, {%{state | max_number: Enum.random(0..100)}, config}}

      error ->
        Logger.error("User points update failed! - #{error}")
        raise "User points update failed!"
    end
  end

  # set timer
  defp schedule_update(interval) do
    Process.send_after(self(), :update_user_points, interval)
  end

  # build results in common format
  defp build_results(result_name, timestamp, func, args) when is_atom(result_name) do
    case func.(args) do
      users when is_list(users) ->
        {:ok, %{result_name => users, timestamp: timestamp}}

      _ ->
        {:error, "User query failed!"}
    end
  end

  defp build_configuration_from_opts(opts) do
    required_config = [:update_interval, :max_num_range, :min_num_range, :users_returned_limit]
    Enum.reduce(required_config, %{}, fn attr, acc ->
      Map.put(acc, attr, Access.get(opts, attr, get_default(attr)))
    end)
  end

  defp get_default(:update_interval), do: Application.get_env(:remote, :update_interval) || 60_000
  defp get_default(:max_num_range), do: Application.get_env(:remote, :max_num_range) || 100
  defp get_default(:min_num_range), do: Application.get_env(:remote, :min_num_range) || 0
  defp get_default(:users_returned_limit), do: Application.get_env(:remote, :users_returned_limit) || 2

end
