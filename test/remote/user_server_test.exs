defmodule Remote.UserServerTest do
  use ExUnit.Case, async: true

  setup do
    user_server = start_supervised!({Remote.Users.UserServer, name: __MODULE__})
    %{user_server: user_server}
  end

  test "get state", %{user_server: user_server} do
    assert %{max_number: _num, timestamp: nil} = Remote.Users.UserServer.get_state(user_server)
  end
end
