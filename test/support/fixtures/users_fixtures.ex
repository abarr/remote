defmodule Remote.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Remote.Users` context.
  """

  def seed_users(number, max, min) do
    Ecto.Adapters.SQL.query!(
      Remote.Repo,
      """
      INSERT INTO users (points, inserted_at, updated_at)
      SELECT floor(random() * (#{max} - #{min})) + #{min}, now() at time zone 'utc', now() at time zone 'utc'
      FROM generate_series(1, #{number});
      """
    )
  end
end
