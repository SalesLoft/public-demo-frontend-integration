$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require './boot'
require 'yaml/store'
require_relative 'lib/secrets'
require_relative 'lib/urls'
require_relative 'lib/token'
require_relative 'lib/simple_api'
require_relative 'lib/store'
require 'securerandom'

Dotenv.load

if !ENV["REDIS_URL"].nil?
  STORE_CLASS = Store::Redis
else
  STORE_CLASS = Store::LocalYaml
end

class App < Sinatra::Application
  configure do
    urls = Urls.for_env
    secrets = Secrets.for_env

    use Rack::Session::Cookie

    use OmniAuth::Builder do
      provider :salesloft, secrets.app_id, secrets.app_secret,
      client_options: {
        site: urls.site_url,
        authorize_url: urls.authorize_url,
        token_url: urls.token_url
      },
      origin_param: 'return_to' # support ?return_to=blah param
    end

    set :protection, except: :frame_options
  end

  get '/auth/failure' do
    request.inspect
  end

  # Receives a POST from SalesLoft integrations with the tenant_id, integration_id, and encrypted payload.
  #   The payload must be decrypted using JWE
  #   This payload is just printed to the screen, there is no app logic.
  post '/portal/echo' do
    tenant_id = request.params["tenant_id"]
    integration_id = request.params["integration_id"]
    content_id = SecureRandom.uuid()
    store = STORE_CLASS.new(tenant_id, integration_id)
    secret = store.get_property(:secret)
    jwk = JOSE::JWK.from_oct(Digest::SHA256.digest(secret))
    payload = jwk.block_decrypt(request.params["payload"])[0]
    decrypted = JSON.parse(payload)
    origin = decrypted.fetch("origin")

    button = ""
    if id = decrypted.dig("action", "id")
      nonce = decrypted.fetch("nonce")
      button = <<-HTML
      <div>
        <a href="/#{tenant_id}/#{integration_id}/complete/action/#{id}/#{nonce}?origin=#{origin}">Complete Action</a>
      </div>
      HTML
    end

    insert_html = ""
    if request.params["type"] && request.params["type"] == "email_editor"
      insert_html = '<p><a id="insertSomeHtml" href="#">Insert some HTML</a></p>'
    end

    <<-HTML
      <html>
        <body>
          #{button}
          <p><a href="/other">Other Page</a></p>
          #{insert_html}
          <pre>#{request.params.merge(decrypted: decrypted, content_id: content_id).to_json}</pre>

          <script type="text/javascript" src="/buttons.js"></script>
          <script type="text/javascript">
            window.json = #{request.params.merge(decrypted: decrypted, content_id: content_id).to_json}
            document.getElementById("insertSomeHtml").onclick = () => {
              let str = "<strong>SalesLoft</strong><span> HTML demo</span>";
              if (json.decrypted.person) {
                str += ` <strong>Person:</strong><span>${json.decrypted.person.id}</span>`;
              }

              window.parent.postMessage({event: "insertHtml", html: `<span>${str}</span>`, nonce: json.decrypted.nonce}, json.decrypted.origin);
              return false;
            };
          </script>
          <br>
        </body>
      </html>
    HTML
  end

  get '/other' do
    <<-HTML
      <html>
        <body>
          <p>On the other page. There's nothing to do here.</p>

          <script type="text/javascript" src="/buttons.js"></script>
        </body>
      </html>
    HTML
  end

  get '/:tenant_id/:integration_id/complete/action/:id/:nonce' do
    tenant_id = params.fetch(:tenant_id)
    integration_id = params.fetch(:integration_id)
    id = params.fetch(:id)
    nonce = params.fetch(:nonce)
    origin = params.fetch(:origin)
    store = STORE_CLASS.new(tenant_id, integration_id)
    token = Token.new(store).access_token
    api = SimpleApi.new(access_token: token)

    # The action must be completed through the API
    result = api.complete_action(id)

    <<-HTML
    <html>
      <body>
        <div>Completed #{id}</div>

        <pre>#{result.to_json}</pre>

        <script type="text/javascript">
          window.parent.postMessage({event: "completedAction", actionId: #{id}, nonce: '#{nonce}'}, "#{origin}");
        </script>
      </body>
    </html>
    HTML
  end

  # Handle receiving a succesful OAuth. We must store the credentials and the secret in
  #   such a way that can be retrieved using the tenant / integration ID
  get '/auth/salesloft/callback' do
    credentials = request.env['omniauth.auth'][:credentials]
    tenant_id = request.env['omniauth.strategy'].access_token["tenant_id"]
    integration_id = request.env['omniauth.strategy'].access_token["integration_id"]
    store = STORE_CLASS.new(tenant_id, integration_id)
    store.save_credentials!(credentials)
    store.save_secret!(request.env['omniauth.strategy'].access_token["secret"])

    origin = request.env['omniauth.origin']
    redirect origin.nil? ? '/success' : origin
  end
end
