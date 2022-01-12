defmodule RemoteWeb.Router do
  use RemoteWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RemoteWeb do
    pipe_through :api

    get "/", UserController, :index
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: RemoteWeb.Telemetry
    end
  end
end
