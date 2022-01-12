defmodule RemoteWeb.ErrorView do
   @moduledoc false
  use RemoteWeb, :view

  def render("error.json", %{msg: msg}) do
    %{error: msg}
  end

  def render("500.json", _) do
    %{errors: "Internal Server Error"}
  end

  def render("404.json", _) do
    %{errors: "Not Found"}
  end

end
