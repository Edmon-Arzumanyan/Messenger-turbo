### Environment Setup

Create a local `.env` file based on `.env.template`: `cp .env.template .env`

Define database credentials in `.env`:

```shell
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=messanger
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
```

Define all other environment variables in `.env`.

### Database Setup

Start Postgres server with `pg_ctl start`

Create and migrate the database:

```shell
rails db:create
rails db:migrate
```

### Seeding

To seed the database with fake data: `rake db:seed`

## Running

- Start all services: `foreman start -f Procfile.dev`
