# AGENTS.md — public-demo-frontend-integration

Owning team: @Salesloft/pde-signals-integrations-apis

## Purpose
Public demo app for Salesloft **Frontend Integrations** (FEI). It shows a third-party developer how to:
- complete the Salesloft OAuth flow and store the per-tenant `secret` returned in the token response,
- receive the encrypted POST that Salesloft sends to integration slot URLs (Custom Action, Email Editor, Full Page) and decrypt it with JWE,
- talk back to the Salesloft UI with `window.parent.postMessage` (`insertHtml`, `completedAction`),
- complete a cadence action via the Salesloft REST API (`POST /v2/activities`).

Consumers are external developers reading the public docs (linked in `README.md`) and internal engineers testing FEI against dev/QA/production. It is not a library and has no internal callers.

## Tech stack & versions
- Ruby `2.7.6` (`.ruby-version`, `.tool-versions`)
- Sinatra `2.2.4` + sinatra-contrib, Rack session cookies, served by Puma `5.6.9`
- OmniAuth `1.8.1` with `omniauth-salesloft` `1.0.0`
- `jose` (JWE decryption), `httparty` (API + token refresh), `redis` `3.3.3` (optional store), `dotenv`, `foreman`
- `Gemfile.lock` records `BUNDLED WITH 4.0.16`
- `rspec` is in the `Gemfile`, but the repo has no specs

## Repository layout
- `app.rb` — the whole Sinatra `App`: OmniAuth config and all routes
- `config.ru` — Rack entrypoint (`run App`)
- `boot.rb` — Bundler setup/require
- `lib/urls.rb` — `Urls`: API/OAuth base URLs per `ENVIRONMENT` (`dev`, `qa`, `qa2`–`qa17`, `production`)
- `lib/secrets.rb` — `Secrets`: reads `SALESLOFT_APP_ID_<env>` / `SALESLOFT_APP_SECRET_<env>`
- `lib/token.rb`, `lib/refresh_token.rb` — access-token lookup and refresh-token exchange
- `lib/simple_api.rb` — `SimpleApi`: small HTTParty client for `/v2` (`create`, `index`, `find`, `delete`, `complete_action`)
- `lib/store.rb`, `lib/store/redis.rb`, `lib/store/yaml.rb` — credential store keyed by tenant id + integration id
- `public/` — static assets (`buttons.js` keeps links from changing the Salesloft window history, `favicon.ico`)
- `Procfile` — hosted process (`bundle exec puma -t 5:5 -p ${PORT}`)
- `Procfile.local` — local HTTPS process using `server.key` / `server.crt`
- `.env.sample` — template for `.env` (variable names only)

## Local setup & common commands
```sh
cp .env.sample .env          # then fill in the app id/secret for your ENVIRONMENT
bundle install
bundle exec foreman start -f Procfile.local
# open https://localhost:8444 and accept the self-signed certificate
```
Register the integration in the Salesloft App Portal using the URLs listed in `README.md` (`https://localhost:8444/auth/salesloft`, `/auth/salesloft/callback`, `/portal/echo`).

## Testing
- There is no automated test suite: no `spec/` directory, no `.rspec`, no CI.
- Verify changes by hand: run the app locally, install the integration in the target Salesloft environment, and use each slot (Custom Action, Email Editor, Full Page).
- Backing services: none are required. Redis is used only when `REDIS_URL` is set. Otherwise credentials are written to local files named `credentials.store.<tenant_id>.<integration_id>`.

## Code conventions & patterns
- Two-space indentation, plain Ruby classes, `require_relative` for files in `lib/`.
- Routes return inline heredoc HTML (`<<-HTML`). There are no templates or views.
- Config objects use a `self.for_env` factory with a default of `ENV.fetch("ENVIRONMENT", "production")`.
- Required env vars are read with `ENV.fetch` (fails fast if missing). Optional ones use `ENV["..."]`.
- The store class is chosen once in `app.rb` (`STORE_CLASS`). Both store classes have the same interface: `get_property`, `save_credentials!`, `save_secret!`, `save_unique_id!`.
- Salesloft API calls go through `SimpleApi` using a bearer token from `Token.new(store).access_token`.
- No linter or formatter is configured (no RuboCop config, no CI gates).

## Configuration (names only)
- `ENVIRONMENT` — selects the `Urls::ENVS` entry and the credential suffix (default `production`)
- `SALESLOFT_APP_ID_<env>`, `SALESLOFT_APP_SECRET_<env>` — one pair per environment, e.g. `SALESLOFT_APP_ID_qa`
- `PORT` — Puma port (`8444` in `.env.sample`)
- `REDIS_URL` — optional. When set, switches to `Store::Redis`.
- `INSECURE_PORT` — listed in `.env.sample` but not read anywhere in the code
- `Dotenv.load` in `app.rb` and foreman both read `.env`.

## CI/CD & deployment overview
- There are no CI workflows, Dockerfile, Helm/k8s/ArgoCD manifests, or CODEOWNERS file in this repo.
- The `Procfile` expects a Procfile-based host that provides `PORT`, and optionally `REDIS_URL`. The repo does not say which host or environment runs it.
- See the deploy-and-release skill for what is known.

## Gotchas
- `ENVIRONMENT` must be a key in `Urls::ENVS`. Otherwise `KeyError` is raised at boot. The matching `SALESLOFT_APP_ID_<env>`/`SALESLOFT_APP_SECRET_<env>` must be set, or `ENV.fetch` raises.
- `SimpleApi::BASE_URI` is computed when the class loads, so `ENVIRONMENT` must be set before `app.rb` loads.
- There is no `GET /` or `GET /success` route. After a callback without `return_to`, the app redirects to `/success`, which returns 404.
- `/portal/echo` needs a stored `secret` for that tenant/integration. Install the integration (OAuth callback) first, or decryption fails.
- An OAuth app (not a Frontend Integration) produces `credentials.store..` with a blank secret (see `README.md`).
- `server.key`/`server.crt` are a committed self-signed demo pair for localhost only. Never reuse them, and never print the key.
- `.env` and `credentials.store*` are git-ignored. Never commit them or show their contents.
- `set :protection, except: :frame_options` is required because Salesloft embeds the pages in iframes.
- Links in slot pages need `public/buttons.js`, which uses `location.replace` so the Salesloft history is not changed.

## Skills
- `.agents/skills/public-demo-frontend-integration-run-and-test-locally/SKILL.md`
- `.agents/skills/public-demo-frontend-integration-add-feature/SKILL.md`
- `.agents/skills/public-demo-frontend-integration-deploy-and-release/SKILL.md`
