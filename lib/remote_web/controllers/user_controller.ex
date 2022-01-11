defmodule RemoteWeb.UserController do
  use RemoteWeb, :controller

  alias Remote.Users

  action_fallback RemoteWeb.FallbackController

  def index(conn, _params) do
    payload = Users.list_users()
    render(conn, "index.json", payload: payload)
  end

end
