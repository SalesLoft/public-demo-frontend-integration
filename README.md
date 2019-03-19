# Demo Frontend Integration

You can read our documentation at [developers.salesloft.com](https://developers.salesloft.com/api.html#!/Topic/Fei_Introduction).

You will need to create a Frontend Integration through the
[SalesLoft App Portal](https://accounts.salesloft.com/frontend_integrations). You
can use the following form parameters for this demo:

* Auth Redirect URL: https://localhost:8444/auth/salesloft
* Callback URLs: https://localhost:8444/auth/salesloft/callback
* Custom Action Slot Url: https://localhost:8444/portal/echo
* Email Editor Slot Url: https://localhost:8444/portal/echo
* Full Page Slot Url: https://localhost:8444/portal/echo

After creating the integration, you can "install" it in the management section of
the App Portal.

## Running the App

1. Copy `.env.sample` to `.env`
1. Fill out the id / secret with your information from App Portal
1. unbocks-rbenv (from https://github.com/SalesLoft/bocksen/tree/master/bin)
1. unbocks-tls
1. `bundle exec foreman start -f Procfile.local`
1. Go to https://app.salesloft.com/app/settings/integrations and enable the integration
1. The different integration points will now become available for demo

## OAuth vs Frontend App

A Frontend Integration is very similar to OAuth, but comes with more abilities. In particular,
it receives the integration id, tenant id, and secret in its OAuth callback.

In this demo, using an OAuth app will still work, but will produce a file like `credentials.store..`
rather than `credentials.store.1.2`. This store will have authorization credentials,
but a blank secret.

## SSL

This demo uses a self-signed cert which won't be trusted by your browser. When you go
to https://localhost:8444, you will need to trust the insecure certificate.
