<div align="center">

# Kousu App

Ruby on Rails 8 application with PostgreSQL, Tailwind CSS v4, and Docker.

</div>

## Overview

Kousu App is a Rails 8.0 application using a modern, container-friendly stack. It ships with:

- Rails 8, Ruby 3.2.2, PostgreSQL 16
- Hotwire (Turbo + Stimulus), Propshaft
- Tailwind CSS v4 via the official CLI (assets compiled to `app/assets/builds`)
- RSpec for testing, plus RuboCop and Brakeman for quality & security
- Devise (authentication) and Pundit (authorization)
- Dockerfiles for development (`Dockerfile.dev`) and production (`Dockerfile`)

> Note: This repository includes both `Dockerfile` (production) and `docker-compose.yml` (local development). Use Compose for local work and the production Dockerfile for deploys.

## Prerequisites

Choose one of the following setups:

- With Docker: Docker Engine + Docker Compose v2
- Without Docker: Ruby 3.2.2, Node.js 20.19.x, PostgreSQL 16
  - JS tooling can be installed with npm (`package-lock.json` present) or Yarn 3 via Corepack

## Quick Start (Docker)

```bash
# Build and run app + Postgres
docker compose up --build

# App will be available at:
open http://localhost:3000
```

The `web` service waits for the database and runs `bin/rails db:prepare` automatically. Volumes are mounted so code changes reflect immediately.

### Common Docker commands

```bash
# Run a one-off Rails task in the app container
docker compose exec web bin/rails db:migrate

# Open a Rails console
docker compose exec web bin/rails console

# Run the test suite
docker compose exec web bundle exec rspec
```

## Local Development (without Docker)

1) Install dependencies

```bash
brew install postgresql@16 # macOS (or use your OS package manager)
bundle install
npm install        # or: corepack enable && yarn install
```

2) Configure database

Either set `DATABASE_URL` or update `config/database.yml` for your local Postgres. Then:

```bash
bin/rails db:prepare
```

3) Start the app and Tailwind watcher

```bash
# Start Rails
bin/rails s

# In another terminal, build CSS with Tailwind CLI (watch mode)
npx @tailwindcss/cli -i app/assets/stylesheets/application.tailwind.css \
  -o app/assets/builds/application.css --watch
```

You should now be able to visit http://localhost:3000.

## Testing & Quality

- Run tests: `bundle exec rspec`
- Lint Ruby: `bundle exec rubocop`
- Security scan: `bundle exec brakeman`

RSpec is preconfigured via `.rspec`. Coverage artifacts and reports are excluded from VCS via `.gitignore`.

## Tailwind CSS v4 Notes

- Source: `app/assets/stylesheets/application.tailwind.css`
- Output: `app/assets/builds/application.css` (the builds directory is on the Rails assets path)
- The project uses Tailwind v4’s CLI. In CI/production, CSS is built during `assets:precompile`.

## Environment Variables

- `DATABASE_URL`: Postgres connection string used by Rails.
- `RAILS_MASTER_KEY`: Required in production to decrypt credentials. Provide via environment variable or mount `config/master.key` securely.
- `PORT`: App port (default: 3000 in development).

For production, additional database roles may be used (cache, queue, cable) as configured in `config/database.yml`.

## Production Build & Run (Docker)

```bash
# Build a production image
docker build -t kousu_app .

# Run the container (example: map to host port 8080)
docker run --rm -p 8080:80 \
  -e RAILS_MASTER_KEY=your_master_key_here \
  --name kousu_app kousu_app

# Visit http://localhost:8080
```

The production image precompiles assets and starts the app via `thruster`. Ensure the database is reachable and migrations are applied.

## Project Structure (high level)

- `app/` — Rails MVC code, views (Hotwire), and Tailwind sources
- `app/assets/builds/` — Compiled CSS output (kept out of VCS except `.keep`)
- `config/` — Application and environment configuration
- `db/` — Migrations and schema
- `spec/` — RSpec tests
- `Dockerfile`, `Dockerfile.dev`, `docker-compose.yml` — Containerization

## Troubleshooting

- Postgres not ready: Compose will retry; check logs with `docker compose logs -f db web`.
- Missing CSS: Ensure the Tailwind build step ran and `application.css` exists under `app/assets/builds`.
- Master key error in production: Set `RAILS_MASTER_KEY` or provide `config/master.key`.

## Authored with Codex CLI

This README was authored and organized with the help of Codex CLI (an open-source, terminal-based AI coding assistant by OpenAI). Changes made via Codex:

- Strengthened `.gitignore` for Rails/RSpec/Tailwind/editor artifacts
- Wrote and replaced the English `README.md` (this file)

Date: 2025-09-13

## License

Add your license here (MIT, Apache-2.0, etc.).
