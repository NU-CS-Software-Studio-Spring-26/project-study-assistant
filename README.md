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

Database credentials and the AI study-plan API key should be provided with environment variables instead of committed secrets:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
DATABASE_URL=postgres://user:password@host/database
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-4.1-mini
OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions
```

For local development, copy `.env.example` to `.env`, then fill in your own values. If `OPENAI_API_KEY` is missing, the dashboard study plan falls back to a local heuristic summary.

### OpenAI setup

1. Create or sign in to your OpenAI account.
2. Generate an API key in your account settings.
3. Put that key into `OPENAI_API_KEY` in your `.env` file.
4. Optional: override `OPENAI_MODEL` or `OPENAI_BASE_URL` if you are using a different provider or deployment.

### Heroku setup

Set the same values as config vars on Heroku:

```bash
heroku config:set OPENAI_API_KEY=your_openai_api_key
heroku config:set OPENAI_MODEL=gpt-4.1-mini
heroku config:set OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions
```

If you do not set the API key, the app still works and shows the local fallback study plan.

## Data Model

The application uses PostgreSQL with Active Record migrations. The current schema includes:

- `users`: account profile, email, password digest, and optional Canvas iCal URL.
- `assignments`: user-owned assignment records with due dates, estimated hours, Canvas IDs, source metadata, and due-time confirmation.
- `study_groups`: user-created study groups with course, topic, meeting time, capacity, and optional join password.
- `group_memberships`: membership records connecting users to study groups.
- `study_group_messages`: chat messages posted inside study groups.

Run migrations locally with:

```bash
ruby bin/rails db:prepare
```

Load demo data with:

```bash
ruby bin/rails db:seed
```

## Deployment

Current Heroku deployment:

https://calm-river-85968-8e2e9aa9b5a5.herokuapp.com/

To deploy this branch to a new Heroku app:

```bash
heroku login
heroku apps:create
heroku addons:create heroku-postgresql:essential-0
heroku config:set SECRET_KEY_BASE="$(ruby bin/rails secret)"
heroku config:set SOLID_QUEUE_IN_PUMA=true
git push heroku milestone1:main
heroku run rails db:prepare
heroku run rails db:seed
heroku open
```

Notes:

- The app reads production database credentials from Heroku's `DATABASE_URL`.
- Do not commit secrets such as `SECRET_KEY_BASE`; set them as Heroku config vars.
- After deploying a new app, replace the current Heroku URL above with the new app URL.

## Team

Andrew, Jace, Natalie, Ken
