defmodule RemoteWeb.ErrorViewTest do
  use RemoteWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(RemoteWeb.ErrorView, "404.json", []) == %{errors: "Not Found"}
  end

  test "renders 500.json" do
    assert render(RemoteWeb.ErrorView, "500.json", []) ==
             %{errors: "Internal Server Error"}
  end
end
