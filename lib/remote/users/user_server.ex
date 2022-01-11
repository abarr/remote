defmodule Remote.Users.UserServer do
  @moduledoc false
  use GenServer

  import Ecto.Query, warn: false
  alias Remote.Repo

  # alias Remote.Users.User

  @update_interval Application.get_env(:remote, :update_interval) || 60_000
  @max Application.get_env(:remote, :update_interval) || 100
  @min Application.get_env(:remote, :update_interval) || 0

  def start_link(opts) do
    name = Access.get(opts, :name, __MODULE__)
    update_interval = Access.get(opts, :update_interval, @update_interval)
    GenServer.start_link(__MODULE__, %{update_interval: update_interval}, name: name)
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

  @impl true
  def handle_info(:update_user_points, {state, config}) do
    with num_rows <- Repo.one(from u in "users", select: count(u.id)),
         {:ok, %{num_rows: rows}} when rows == num_rows <-
           Ecto.Adapters.SQL.query(
             Repo,
             """
             UPDATE users
             SET
              points = floor(random() * (#{@max} - #{@min})) + #{@min},
              updated_at = now() at time zone 'utc';
             """
           ) do
      IO.puts("Number of rows updated: #{num_rows}")
    else
      _ -> raise "User points update failed!"
    end

    schedule_update(config.update_interval)
    {:noreply, {%{state | max_number: Enum.random(0..100)}, config}}
  end

  # set timer
  defp schedule_update(interval) do
    Process.send_after(self(), :update_user_points, interval)
  end
end
