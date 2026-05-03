# Study Assistant

Study Assistant is a Rails app for students who need one place to manage assignments and coordinate study groups.

## MVP

- Password-protected signup, login, and logout.
- Personal assignment dashboard with create, read, update, delete, search, and sort.
- Study group discovery with create, read, update, delete, optional join passwords, membership, and group chat.
- Bootstrap UI with consistent navigation, flash messages, empty states, and validation errors.
- Realistic demo data through `db:seed`.

## Getting Started

Install dependencies and prepare the database:

```bash
bundle install
ruby bin/rails db:prepare
ruby bin/rails db:seed
```

Run the app:

```bash
ruby bin/rails server
```

Run checks:

```bash
ruby bin/rails test
ruby bin/rubocop
ruby bin/brakeman --no-pager
ruby bin/bundler-audit
```

## Configuration

Database credentials should be provided with environment variables instead of committed secrets:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
DATABASE_URL=postgres://user:password@host/database
```

## Deployment

Heroku deployment:

https://calm-river-85968-8e2e9aa9b5a5.herokuapp.com/

## Team

Andrew, Jace, Natalie, Ken

## Communication

The team will track work on the project board, keep active tasks assigned, and use pull requests for review before merging. Decisions that affect scope, data, or user workflow should be written in the relevant issue or pull request so everyone can follow the reasoning. Team members should communicate blockers early and keep commits focused with descriptive messages.
