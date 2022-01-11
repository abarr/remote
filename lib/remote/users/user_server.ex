defmodule Remote.Users.UserServer do
  @moduledoc false
  use GenServer

  alias Remote.Users.BuildQuery
  require Logger

  @update_interval Application.get_env(:remote, :update_interval) || 60_000
  @max_num_range Application.get_env(:remote, :update_interval) || 100
  @min_num_range Application.get_env(:remote, :update_interval) || 0
  @users_returned_limit Application.get_env(:remote, :limit) || 2

  #  This GenServer starts with the following state:
  #   {
  #     %{
  #       max_number: #Random number bewteen the configurabe values - defaults to 0-100},
  #       timestamp: nil
  #     },
  #     %{
  #       update_interval: # The time set for calling schedule_update/1
  #       max_num_range: # The max number in the range for generating random numbers
  #       min_num_range: # The min number in the range for generating random numbers
  #       users_returned_limit: # sets the limit for the number of users to return - defaults to 2
  #     }
  #   }
  #
  def start_link(opts) do
    name = Access.get(opts, :name, __MODULE__)
    update_interval = Access.get(opts, :update_interval, @update_interval)
    max_num_range = Access.get(opts, :max_num_range, @max_num_range)
    min_num_range = Access.get(opts, :max_num_range, @min_num_range)
    users_returned_limit = Access.get(opts, :max_num_range, @users_returned_limit)

    GenServer.start_link(
      __MODULE__,
      %{
        update_interval: update_interval,
        max_num_range: max_num_range,
        min_num_range: min_num_range,
        users_returned_limit: users_returned_limit
      },
      name: name
    )
  end

  @impl true
  def init(config) do
    Logger.info("#{__MODULE__} - successfully created")
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

    Logger.info("Remote.Users.UserServer :max_number updated and Users returned")

    {:reply, result, {%{state | timestamp: DateTime.utc_now()}, config}}
  end

  @impl true
  #  Based on the update_interval the server will update the points value for all users to a random integer
  #  between the min and max range defined in the configuration (The second value in the state tuple).
  def handle_info(:update_user_points, {state, config}) do
    with num_rows <- BuildQuery.get_table_row_count(),
         {:ok, %{num_rows: rows}} when rows == num_rows <-
           BuildQuery.update_all_users_points(config.max_num_range, config.min_num_range) do
      Logger.info("User rows updated with new random points value: #{num_rows}")
      schedule_update(config.update_interval)
      {:noreply, {%{state | max_number: Enum.random(0..100)}, config}}
    else
      _ ->
        Logger.error("User points update failed!")
        raise "User points update failed!"
    end
  end

  # set timer
  defp schedule_update(interval) do
    Process.send_after(self(), :update_user_points, interval)
  end

  # build results in common format
  defp build_results(result_name, timestamp, func, args) when is_atom(result_name) do
    %{
      result_name => func.(args),
      timestamp: timestamp
    }
  end
end
