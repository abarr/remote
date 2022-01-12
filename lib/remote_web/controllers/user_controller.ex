defmodule RemoteWeb.UserController do
  @moduledoc """
  Handles API calls to root of application
  """
  use RemoteWeb, :controller

  alias Remote.Users

  action_fallback RemoteWeb.FallbackController

  @doc """
  Default call to some_domain.com returns a json payload

    {
      'users': [{id: 1, points: 30}, {id: 72, points: 30}],
      'timestamp': `2020-07-30 17:09:33`
    }

  """
  def index(conn, _params) do
    {:ok, payload} = Users.list_users()
    render(conn, "index.json", payload: payload)
  end

end
