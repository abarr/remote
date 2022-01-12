defmodule Remote.Users.BuildQuery do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Remote.Repo

  def list_by_points_greater_than_with_limit({points, limit}) do
    all("users")
    |> with_points_greater_than(points)
    |> with_limit(limit)
    |> user_to_map()
    |> Repo.all()
  end

  def update_all_users_points(max, min) do
    Enum.each(update_sql(min, max), fn sql ->
      Ecto.Adapters.SQL.query(Repo, sql)
    end)
  end

  defp all(user) do
    from(_u in user)
  end

  defp with_points_greater_than(query, points) do
    from q in query,
      where: q.points > ^points
  end

  defp with_limit(query, limit) do
    from q in query,
      limit: ^limit
  end

  defp user_to_map(query) do
    from q in query,
      select: %{id: q.id, points: q.points}
  end

  defp update_sql(min, max) do
    [
      """
      CREATE TABLE updated_users (id, points, inserted_at, updated_at) AS
       SELECT id, cast(floor(random() * (#{max} - #{min})) + #{min} AS integer) , inserted_at, now() at time zone 'utc'
        FROM users;
      """,
      """
      DROP TABLE users;
      """,
      """
      ALTER TABLE updated_users RENAME TO users;
      """
    ]
  end
end
