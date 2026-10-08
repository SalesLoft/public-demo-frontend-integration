---
name: public-demo-frontend-integration-deploy-and-release
description: What the repo shows about releasing the Salesloft Frontend Integration demo: no CI, image build, or k8s/ArgoCD config; only a Procfile for a Procfile-based host. Use before shipping a change or when asked how the demo is deployed or rolled back.
---

# Deploy and release

## 1. What exists in this repo
- `Procfile`: `web: bundle exec puma -t 5:5 -p ${PORT}`. This is the only production-style process definition.
- `config.ru`: `run App`, the Rack entrypoint Puma loads.
- Runtime config is read from env vars: `ENVIRONMENT`, `SALESLOFT_APP_ID_<env>`, `SALESLOFT_APP_SECRET_<env>`, `PORT`, and optionally `REDIS_URL`.
- `.ruby-version` / `.tool-versions`: Ruby `2.7.6`.

## 2. What does not exist (do not invent it)
- No `.github/workflows/`, Buildkite, CircleCI or other CI config.
- No `Dockerfile`, image build, or registry (e.g. Harbor) references.
- No Helm, Kubernetes, kustomize or ArgoCD manifests, and no references to `k8s-services-config-*` or `kubernetes-argocd-*`.
- No version file, changelog, git tags process, or gem/package publishing. This is an app, not a library.
- No CODEOWNERS file. The owning team is @Salesloft/pde-signals-integrations-apis.

Where the demo is hosted, and whether a hosted copy exists at all, is **not documented in this repo**. Ask the owning team before assuming a target.

## 3. Release flow that the repo supports
1. Verify the change locally (see the run-and-test-locally skill), including a real Salesloft install against the target `ENVIRONMENT`.
2. Open a PR. There are no automated checks, so the description should list:
   - which slot(s)/routes changed and how you tested them,
   - any new env var names (already added to `.env.sample`),
   - whether the store interface changed (Redis and YAML).
3. After review and merge (a human merges), deploy to whatever Procfile-based host the team uses. The host must:
   - run `bundle install` with Ruby `2.7.6`,
   - start the `web` process from `Procfile` with `PORT` provided,
   - provide `ENVIRONMENT` and the matching `SALESLOFT_APP_ID_<env>` / `SALESLOFT_APP_SECRET_<env>` through its secret/config mechanism,
   - set `REDIS_URL`. Without it, `Store::LocalYaml` writes credential files to the local disk, which may not persist or be shared between instances.
4. Update the Frontend Integration in the Salesloft App Portal so its Auth Redirect, Callback and slot URLs point at the hosted base URL (local values are in `README.md`).

## 4. Configuration changes
- New env vars: add the name to `.env.sample` (no value) and set the real value in the host's secret store. Never put values in the repo, PR or logs.
- New Salesloft environment: add it to `Urls::ENVS` in `lib/urls.rb` and add the matching credential pair to the host.

## 5. Verify after deploy
1. Puma starts and listens on `PORT` (check the host's process logs).
2. In Salesloft, enable the integration at `/app/settings/integrations` for the target environment. The OAuth callback should finish without hitting `/auth/failure`.
3. Open each slot (Custom Action, Email Editor, Full Page). `/portal/echo` should render the decrypted payload.
4. If using Redis, check that the key `DemoFrontendIntegration::credentials.store.<tenant_id>.<integration_id>` exists. Do not print its value.

## 6. Rollback
- There is no automated rollback in this repo. Roll back by redeploying the previous commit on the host, or by reverting the PR and redeploying.
- If a change altered stored data shape, check that the previous code can still read existing Redis keys / YAML files. Both stores keep JSON/YAML hashes with `credentials`, `secret` and `unique_id`.
- If the App Portal URLs were changed, change them back to match the restored deployment.

## 7. Open questions to raise with the team
- Which host/environment runs the `Procfile` (if any), and who has access.
- Whether Ruby `2.7.6` and the `BUNDLED WITH 4.0.16` Bundler version in `Gemfile.lock` are what the host actually uses.
