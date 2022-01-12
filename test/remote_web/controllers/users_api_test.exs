defmodule RemoteWeb.UserApiTest do
  use ExUnit.Case, async: false
  use RemoteWeb.ConnCase, async: false

  import Remote.UsersFixtures


  describe "API Tests" do
    @default_limit 2

    setup do
      seed_users(100, 100, 0)
      :ok
    end

    test "call API", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      list = json_response(conn, 200)["users"]

      assert is_list(list)
      assert not Enum.empty?(list)
    end

    test "test that the payload users list matches the default limit", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      list = json_response(conn, 200)["users"]

      assert Enum.count(list) == @default_limit
    end

    test "test that the timestamp is not nil", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))

      assert json_response(conn, 200)["timestamp"] != nil
    end

    test "test that the timestamp changes between calls", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      timestamp_1 = json_response(conn, 200)["timestamp"]

      :timer.sleep(200)

      conn = get(conn, Routes.user_path(conn, :index))
      timestamp_2 = json_response(conn, 200)["timestamp"]

      assert timestamp_1 != timestamp_2
    end
  end

end
