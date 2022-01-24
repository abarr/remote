defmodule Remote.UserServerModuleTest do
  use ExUnit.Case, async: false

  test "get state" do
    assert {:reply, %{test: "state"}, %{test: "state"}} =
      Remote.Users.UserServer.handle_call(:get_state, %{}, %{test: "state"})
  end

end
