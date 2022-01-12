defmodule RemoteWeb.ErrorView do
   @moduledoc false
  use RemoteWeb, :view

  def render("error.json", %{msg: msg}) do
    %{error: msg}
  end
end
