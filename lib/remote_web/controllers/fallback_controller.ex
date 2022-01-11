defmodule RemoteWeb.FallbackController do
  @moduledoc """
  Catches errors from API calls
  """
  use RemoteWeb, :controller

  def call(conn, {:error, msg}) do
    conn
    |> put_status(:error)
    |> put_view(RemoteAWeb.ErrorView)
    |> render("error.json", status: :error, message: msg)
  end
end
