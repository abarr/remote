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
    Ecto.Adapters.SQL.query(
      Repo,
      """
      UPDATE users
      SET
      points = floor(random() * (#{max} - #{min})) + #{min},
      updated_at = now() at time zone 'utc';
      """
    )
  end

  def get_table_row_count() do
    all("users")
    |> get_count()
    |> Repo.one()
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

  defp get_count(query) do
    from q in query,
      select: count(q.id)
  end
end
