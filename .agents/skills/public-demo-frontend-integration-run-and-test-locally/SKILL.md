---
name: public-demo-frontend-integration-run-and-test-locally
description: Run the Salesloft Frontend Integration demo (Sinatra/Puma over local HTTPS) against dev, QA or production, and check changes by hand. The repo has no automated tests or linters. Use when setting up, running or debugging the app locally.
---

# Run and test locally

## 1. Prerequisites
- Ruby `2.7.6` (from `.ruby-version` / `.tool-versions`). Example with asdf:
  ```sh
  asdf install
  ruby -v
  ```
- Bundler. `Gemfile.lock` says `BUNDLED WITH 4.0.16`. If that Bundler version does not run on Ruby 2.7.6, use a Bundler that does and do not commit lockfile changes unless you mean to.
- A Frontend Integration created in the Salesloft App Portal for the environment you target. Use the URLs from `README.md`:
  - Auth Redirect URL: `https://localhost:8444/auth/salesloft`
  - Callback URL: `https://localhost:8444/auth/salesloft/callback`
  - Slot URLs (Custom Action, Email Editor, Full Page): `https://localhost:8444/portal/echo`

## 2. Configure environment
```sh
cp .env.sample .env
```
Edit `.env` (never commit it or paste its contents anywhere):
- Set `ENVIRONMENT` to a key in `lib/urls.rb` (`dev`, `qa`, `qa2`…`qa17`, `production`).
- Fill in `SALESLOFT_APP_ID_<ENVIRONMENT>` and `SALESLOFT_APP_SECRET_<ENVIRONMENT>`.
- Keep `PORT=8444` so the Portal URLs match.
- Leave `REDIS_URL` unset to use local YAML files (`credentials.store.<tenant>.<integration>`). Set it to use Redis.

## 3. Install dependencies
```sh
bundle install
```

## 4. Backing services
- None required.
- Optional Redis: set `REDIS_URL` in `.env`. `app.rb` then uses `Store::Redis` instead of `Store::LocalYaml`.

## 5. Run the app
```sh
bundle exec foreman start -f Procfile.local
```
`Procfile.local` starts Puma on `ssl://0.0.0.0:$PORT` with the committed self-signed `server.key`/`server.crt`. Open `https://localhost:8444` and accept the certificate warning. The app has no `/` route, so a 404 page is expected. The point is to trust the certificate.

To run the hosted command instead (plain HTTP, no SSL):
```sh
bundle exec foreman start
```

## 6. Exercise the integration (manual test)
1. In Salesloft, open `/app/settings/integrations` for the target environment and enable the integration. This runs OAuth and hits `/auth/salesloft/callback`, which stores credentials and the secret.
2. Check that a `credentials.store.<tenant_id>.<integration_id>` file exists (YAML store) or that the Redis key `DemoFrontendIntegration::credentials.store.<tenant_id>.<integration_id>` exists. Do not print the stored values.
3. Open each slot in Salesloft:
   - Email Editor: click "Insert some HTML". It sends the `insertHtml` postMessage.
   - Custom Action: click "Complete Action". This calls `GET /:tenant_id/:integration_id/complete/action/:id/:nonce`, which calls `SimpleApi#complete_action` and sends the `completedAction` postMessage.
   - Full Page: check that the decrypted payload JSON shows in `<pre>`.
4. Click "Other Page" to check that `public/buttons.js` navigation works inside the iframe.

## 7. Automated tests, lint, static checks
- There are none in this repo: no `spec/`, no `.rspec`, no RuboCop config, no CI workflows. `rspec` is in the `Gemfile` but has no specs.
- A quick syntax check needs no extra tools:
  ```sh
  ruby -c app.rb
  for f in lib/*.rb lib/store/*.rb; do ruby -c "$f"; done
  ```
- To confirm the app boots, run step 5 and watch for Puma's "Listening on ssl://0.0.0.0:8444".

## 8. Common failures
- `KeyError: key not found: "SALESLOFT_APP_ID_<env>"`: the credential pair for `ENVIRONMENT` is missing in `.env`.
- `KeyError` from `Urls::ENVS.fetch`: `ENVIRONMENT` is not one of the keys in `lib/urls.rb`.
- Browser refuses the iframe or connection: you have not accepted the self-signed certificate at `https://localhost:8444` yet.
- `/portal/echo` raises on `Digest::SHA256.digest(nil)` or decryption: there is no stored secret for that tenant/integration. Re-enable the integration to run OAuth again. An OAuth app (not FEI) stores a blank secret.
- 404 on `/success` after install: this is expected. That route is not defined.
- `/auth/failure` prints `request.inspect`. Check the App Portal redirect/callback URLs and the app id/secret.
- Port in use: change `PORT` in `.env` and update the App Portal URLs to match.
