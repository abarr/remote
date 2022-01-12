defmodule RemoteWeb.Api.UserApiTest do
  use ExUnit.Case, async: true
  use Remote.DataCase, async: true

  test "call API", %{conn: conn} do
    conn = get(conn, Routes.user_path(conn, :index))
    assert json_response(conn, 200)["users"] == list when is_list(users)
  end
end
