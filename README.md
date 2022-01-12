# Remote

Remote is a `server` that manages a list of `Users`. Each `User` has `points` (A positive `:integer`).
By default, the `points` will be between 0 and 100; however, an `admin` can configure the range in `Remote's` configuration files (See docs).

The server will periodically update every `User` record with a new randomly generated `:integer` within the 
configured range. The interval between updates defaults to every 60 seconds; however, an `admin` can change it in 
`Remote's` configuration files (See docs).

`Remote` holds a `:max_number` in the state. Each time the `Users` `points` are updated the `:max_number` is updated
with a random value within the configured range.

`Remote`exposes an `API` with a single endpoint `some_domain.com` (See below for details).


## Remote API

### Request 

A call to the `Remote` `API` will return a list with the configured number of `Users` (`id` and `points`) with a `timestamp` 
representing the `utc_datetime` of the last call to the `API`. The default number of `Users` is two (2). 

| Path | Description | Arguments |
| ---- | ----------- | --------- | 
| some_domain.com | Returns `JSON` object with a list of `User` objects and the timestamp for the last call | None |

### Response

```JSON
{
 "timestamp":"2022-01-12T02:27:23.466953Z",
 "users":[
 {"id":1,"points":10},
 {"id":2,"points":57}
 ]
}
```

If an error occurs, you will receive one of the following responses.

```json
{"errors":"Internal Server Error"}
{"errors":"Not Found"}
{"error":"User query failed!"}
```

## Setting up Remote Locally

Start by cloning the repository on `GitHub`, or you can visit the page and download it directly.

```
$ git clone https://github.com/abarr/remote
```

The remainder of the instructions assumes you have `Erlang`, `Elixir` and `Postgres` installed and configured on your machine. If 
not, head over to the official [Elixir](https://elixir-lang.org/install.html) and [`Postgres`](https://www.postgresql.org/download/) 
sites for instructions.

Once you have `Remote` in a local directory `cd ~/remote` and run the following commands:
 * Install dependencies with `mix deps.get`
 * Create and migrate your database with `mix ecto.setup`
 * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:3000`](http://localhost:4000) from your browser. If you have run the application with the default configuration and call the `API` within the first 60 seconds, your response will be as follows.

```json
{"timestamp":null, "users": []}
```

This result occurs because the initial value of `Users` `points` is `0`, and there are no `Users` with a `points` value greater than the `:max_number`. After the configured interval has passed, you will receive results showing the `UTC` timestamp for the last call to the `API` and the first two `Users` with a `points` value greater than the `:max_number` held in the state.

```json
{"timestamp":"2022-01-12T02:19:23.853512Z","users":[{"id":1,"points":97},{"id":3,"points":92}]}
```

If there is only one or no `Users` with `points` values greater than `:max_number`, you will receive a list of one or an empty list, respectively.