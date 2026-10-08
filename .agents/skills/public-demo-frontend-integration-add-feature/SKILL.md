---
name: public-demo-frontend-integration-add-feature
description: Add a change to the Salesloft Frontend Integration demo the way the repo already does it: a new Sinatra route in app.rb, a SimpleApi method, a store property, or a new Salesloft environment in lib/urls.rb. Includes manual verification and a pre-PR checklist.
---

# Add a feature

The whole app is `app.rb` plus small classes in `lib/`. Keep changes small and readable. This is a public sample that external developers copy.

## 1. Pick the change type
| Change | Files |
|---|---|
| New page / slot handler | `app.rb` (+ `public/` for static JS) |
| New Salesloft API call | `lib/simple_api.rb`, called from a route in `app.rb` |
| New persisted value per tenant/integration | `lib/store/redis.rb` **and** `lib/store/yaml.rb` |
| New Salesloft environment | `lib/urls.rb`, `.env.sample` |

## 2. Add a route (pattern: `/portal/echo`, `/:tenant_id/:integration_id/complete/action/:id/:nonce`)
1. Add it inside `class App < Sinatra::Application` in `app.rb`.
2. Get the tenant/integration ids from params, then build the store and token the same way existing routes do:
   ```ruby
   store = STORE_CLASS.new(tenant_id, integration_id)
   token = Token.new(store).access_token
   api = SimpleApi.new(access_token: token)
   ```
3. Return inline heredoc HTML (`<<-HTML ... HTML`), as the other routes do.
4. For any page that has links and is shown inside the Salesloft iframe, include `<script type="text/javascript" src="/buttons.js"></script>`.
5. To talk to Salesloft, call `window.parent.postMessage({...}, origin)`. `origin` comes from the decrypted payload (`decrypted.fetch("origin")`) or from the `origin` query param. Include `nonce` where the existing events include it.
6. To decrypt a slot POST, copy `/portal/echo`:
   ```ruby
   jwk = JOSE::JWK.from_oct(Digest::SHA256.digest(store.get_property(:secret)))
   decrypted = JSON.parse(jwk.block_decrypt(request.params["payload"])[0])
   ```
7. Add a short comment above the route explaining what it shows, like the comments on `/portal/echo` and `/auth/salesloft/callback`.

## 3. Add a `SimpleApi` method (pattern: `complete_action`)
In `lib/simple_api.rb`, add a public method that wraps the generic helpers `create`, `index`, `find` or `delete`. Paths are relative to `/v2`:
```ruby
def complete_action(id)
  create('activities', { action_id: id })
end
```
Do not hard-code hosts. `BASE_URI` comes from `Urls.for_env.api_base`.

## 4. Add a store property
Both stores must keep the same interface, because `STORE_CLASS` is chosen at runtime in `app.rb`.
- Add `save_<name>!(value)` that calls `write_property!(:<name>, value)` to **both** `lib/store/redis.rb` and `lib/store/yaml.rb`.
- Read it with `store.get_property(:<name>)`. The Redis store converts keys to strings, and the YAML store uses symbols. Pass a symbol in both cases.

## 5. Add a Salesloft environment
1. Add a key to `Urls::ENVS` in `lib/urls.rb` with `api_base`, `site`, `authorize_url`, `token_url`. Follow the existing `qaN` entries.
2. Add empty `SALESLOFT_APP_ID_<env>=` / `SALESLOFT_APP_SECRET_<env>=` lines to `.env.sample`. Never add real values.

## 6. Configuration rules
- Required env vars: `ENV.fetch("NAME")`. Optional: `ENV["NAME"]` or `ENV.fetch("NAME", nil)`.
- Document every new variable name in `.env.sample` with no value.
- Do not log or render secrets, tokens or `credentials` in HTML. `/portal/echo` shows request params and decrypted payload only.

## 7. Verify
There is no test suite or CI. Verify by hand:
```sh
ruby -c app.rb
for f in lib/*.rb lib/store/*.rb; do ruby -c "$f"; done
bundle exec foreman start -f Procfile.local
```
Then follow the run-and-test-locally skill, section 6: enable the integration in Salesloft and use the affected slot. If you change storage, test both with and without `REDIS_URL`.

Only add RSpec specs if the change asks for them. `rspec` is in the `Gemfile`, but there is no `spec/` setup yet.

## 8. Pre-PR checklist
- [ ] `ruby -c` passes for each changed `.rb` file.
- [ ] The app boots with `bundle exec foreman start -f Procfile.local`.
- [ ] The affected slot or route works in a real Salesloft environment (state which `ENVIRONMENT`).
- [ ] Both `Store::Redis` and `Store::LocalYaml` are updated if the store interface changed.
- [ ] New env var names are added to `.env.sample` with no values.
- [ ] No `.env`, `credentials.store*`, tokens or secrets are committed. `server.key` is unchanged.
- [ ] `README.md` is updated if setup steps or App Portal URLs changed.
- [ ] Gems are added with `bundle add`, not by editing the `Gemfile` by hand.
