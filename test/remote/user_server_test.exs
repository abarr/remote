defmodule Remote.UserServerTest do
  use ExUnit.Case, async: false
  use Remote.DataCase, async: false

  import Remote.UsersFixtures

  describe "user server test" do
    @update_interval 10_000
    @limit 2
    @test_number_users 100
    @max 100
    @min 0

    setup do
      {:ok, user_server} =
        start_supervised({
          Remote.Users.UserServer,
          name: __MODULE__, update_interval: @update_interval, users_returned_limit: @limit
        })

      seed_users(@test_number_users, @max, @min)
      %{user_server: user_server}
    end

    test "get state", %{user_server: user_server} do
      assert(
      %{
        config: %{
          max_num_range: 100,
          min_num_range: 0,
          update_interval: 10000,
          users_returned_limit: 2
        },
        values: %{
          max_number: _num,
          timestamp: nil
        }
      } = GenServer.call(user_server, :get_state))
    end

    test "get users limited by configuration and greater than max_number" do
      {:ok, server} =
        Remote.Users.UserServer.start_link(name: :timer_test, update_interval: 1_000)

      %{config: _config, values: %{max_number: max_number}} = GenServer.call(server, :get_state)

      {:ok, %{users: users}} = GenServer.call(server, :get_users_points_greater_than_max)

      assert Enum.count(users) <= @limit

      for u <- users do
        assert u.points > max_number
      end
    end

  end
end
