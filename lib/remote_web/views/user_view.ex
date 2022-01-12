defmodule RemoteWeb.UserView do
  @moduledoc false
  use RemoteWeb, :view

  def render("index.json", %{payload: payload}) do
    payload
  end
end
