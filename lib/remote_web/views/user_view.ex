defmodule RemoteWeb.UserView do
  use RemoteWeb, :view

  def render("index.json", %{payload: payload}) do
    payload
  end
end
