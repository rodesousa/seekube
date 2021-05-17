# Seekube

[Statement](./statement.md)

## To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

## How to test ?

+ Set MONGO_URL variable (export MONGO_URL="mongo+srv....")
+ Request POST:

```
{
    "query": "WHERE data.slug = jobdating-conseil-et-finance1"
}
```

```
{
    "query": "WHERE data.slug = jobdating-conseil-et-finance1 OR data.slug = forum-virtuel-mines-nancy"
}
```

```
{
    "query": "WHERE data.slug = jobdating-conseil-et-finance1 AND data.acceptedApplications = 3.0"
}
```

