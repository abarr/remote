defmodule Remote.Users do
  @moduledoc """
  The Users context.
  """

  @doc """
  Returns a map with a list of users that have points greater than the
  max_number value held in system state (See Remote.Users.UserServer).

  The results is limited to a configurable value that defaults to 2
  (See Remote.Users.UserServer).

  A timestamp is included in the map that is the utc_datetime of the last
  call made to the server.

  ## Examples

      iex> list_users()
      %{
        users: [%{id: 1, points: 56}, ...],
        timestamp: ~U[2022-01-11 05:01:00.763516Z]
      }

  """
  def list_users(server \\ Remote.Users.UserServer) do
    GenServer.call(server, :get_users_points_greater_than_max)
  end
end
