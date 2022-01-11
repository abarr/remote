# Generate 1,000,000 rows in the User table using raw SQL
# defaulting the points column to 0
Ecto.Adapters.SQL.query!(
  Remote.Repo,
  """
  INSERT INTO users (points, inserted_at, updated_at)
  SELECT 0, now() at time zone 'utc', now() at time zone 'utc'
  FROM generate_series(1, 1000000);
  """
)
