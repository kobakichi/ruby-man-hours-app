<div align="center">

# Kousu App Monorepo

Time tracking app (Rails 8) + Rails application template.

<p>
  <a href="https://www.ruby-lang.org/">
    <img alt="Ruby 3.2.2" src="https://img.shields.io/badge/Ruby-3.2.2-CC342D?logo=ruby&logoColor=white" />
  </a>
  <a href="https://rubyonrails.org/">
    <img alt="Rails 8" src="https://img.shields.io/badge/Rails-8.0-CC0000?logo=rubyonrails&logoColor=white" />
  </a>
  <a href="https://www.postgresql.org/">
    <img alt="PostgreSQL 16" src="https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white" />
  </a>
  <a href="https://nodejs.org/">
    <img alt="Node.js 20" src="https://img.shields.io/badge/Node.js-20-339933?logo=node.js&logoColor=white" />
  </a>
  <a href="https://tailwindcss.com/">
    <img alt="Tailwind CSS v4" src="https://img.shields.io/badge/Tailwind_CSS-4.1-06B6D4?logo=tailwindcss&logoColor=white" />
  </a>
  <a href="#testing--quality">
    <img alt="Tests: RSpec" src="https://img.shields.io/badge/Tests-RSpec-6D2E85" />
  </a>
  <a href="#testing--quality">
    <img alt="Code Style: RuboCop" src="https://img.shields.io/badge/Code_Style-RuboCop-000000" />
  </a>
  <a href="#testing--quality">
    <img alt="Security: Brakeman" src="https://img.shields.io/badge/Security-Brakeman-E74C3C" />
  </a>
  <a href="#quick-start-docker">
    <img alt="Dockerized: Compose" src="https://img.shields.io/badge/Dockerized-Compose-2496ED?logo=docker&logoColor=white" />
  </a>
  <a href="https://www.conventionalcommits.org/en/v1.0.0/">
    <img alt="Conventional Commits" src="https://img.shields.io/badge/Conventional_Commits-1.0.0-FE5196?logo=conventionalcommits&logoColor=white" />
  </a>
</p>

</div>

## Overview

This repo contains two related things:

- `kousu_app/`: a Rails 8.0 application using Ruby 3.2.2, PostgreSQL 16, Tailwind CSS v4, RSpec, RuboCop and Brakeman. It includes `Dockerfile`, `Dockerfile.dev`, and `docker-compose.yml` for containerized development and production builds.
- `rails_template.rb`: a Rails Application Template that scaffolds the same time tracking app from scratch via `rails new ... -m rails_template.rb`.

Design documents live under `docs/` (currently written in Japanese):

- ERD (Mermaid): `docs/erd.mmd`
- MVP backlog: `docs/mvp_backlog.md`

If you just want to run the app, go to Quick Start. If you want to generate a fresh app in a new directory, see Use the Application Template.

## Repository Layout

- `kousu_app/` — Rails 8 time tracking app (Hotwire, Devise, Pundit, Tailwind v4)
- `docs/` — ERD and backlog (Japanese)
- `rails_template.rb` — Rails Application Template to bootstrap the same app

## Quick Start (Docker)

```bash
cd kousu_app
docker compose up --build

# App will be available at:
open http://localhost:3000
```

The `web` service waits for PostgreSQL and runs `bin/rails db:prepare` automatically. Volumes are mounted for live reload.

### Common Docker commands

```bash
# Run migrations in the app container
docker compose exec web bin/rails db:migrate

# Rails console
docker compose exec web bin/rails console

# Run the test suite
docker compose exec web bundle exec rspec
```

## Local Development (without Docker)

Prerequisites: Ruby 3.2.2, Node.js 20.19.x, PostgreSQL 16.

```bash
cd kousu_app
brew install postgresql@16           # macOS example
bundle install
npm install                          # or: corepack enable && yarn install

# DB setup
bin/rails db:prepare

# Start Rails
bin/rails s

# In another terminal, watch CSS (Tailwind v4 CLI)
npx @tailwindcss/cli -i app/assets/stylesheets/application.tailwind.css \
  -o app/assets/builds/application.css --watch
```

Visit http://localhost:3000.

## Use the Application Template

You can scaffold a fresh project elsewhere using the included template:

```bash
rails new kousu_app \
  -d postgresql -j esbuild -c tailwind \
  -m /absolute/path/to/rails_template.rb
```

After generation:

```bash
cd kousu_app
bin/rails db:setup
bin/rails s
```

Default demo login (seeded):

- Email: `admin@example.com`
- Password: `password`

## Production (Docker)

Build a production image from `kousu_app/Dockerfile`:

```bash
cd kousu_app
docker build -t kousu_app .
docker run --rm -p 8080:80 \
  -e RAILS_MASTER_KEY=your_master_key_here \
  --name kousu_app kousu_app

# Visit http://localhost:8080
```

The image precompiles assets and launches via `thruster`. Ensure the database is reachable and migrations are applied.

## Testing & Quality

- Tests: `bundle exec rspec`
- Lint: `bundle exec rubocop`
- Security: `bundle exec brakeman`

RSpec is configured via `.rspec`. Temporary artifacts are ignored by `.gitignore`.

## Environment Variables

- `DATABASE_URL` — Postgres connection string
- `RAILS_MASTER_KEY` — Required to decrypt credentials in production
- `PORT` — App port (3000 in dev, 80 in production image)

## Notes

- CI/CD workflows are not included. Add your own under `.github/workflows/` if needed.
- Dependabot config is present under `kousu_app/.github/dependabot.yml`.

## Contributing

We follow Conventional Commits. Please include in PR descriptions: Background → Changes → Verification → Risks → Learning.

## License

Add your license (e.g., MIT or Apache-2.0).

---

Authored with Codex CLI — an open-source, terminal-based AI coding assistant by OpenAI.

