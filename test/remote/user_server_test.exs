defmodule Remote.UserServerTest do
  use ExUnit.Case, async: true
  use Remote.DataCase, async: true

  describe "user server test" do
    @update_interval 10_000

    setup do
      {:ok, user_server} = start_supervised({Remote.Users.UserServer, name: __MODULE__, update_interval: @update_interval})
      %{user_server: user_server}
    end

    test "get state", %{user_server: user_server} do
      assert {%{max_number: _max_number, timestamp: nil}, %{update_interval: 10000}} = GenServer.call(user_server, :get_state)
    end

    test "checks server state changes based on timer" do

      {:ok, server} =
        Remote.Users.UserServer.start_link(name: :timer_test, update_interval: 1_000)

        {%{max_number: max_number}, _} = GenServer.call(server, :get_state)

      :timer.sleep(1_500)

      {%{max_number: new_max_number}, _} =GenServer.call(server, :get_state)

      assert max_number != new_max_number
    end

  end
end
