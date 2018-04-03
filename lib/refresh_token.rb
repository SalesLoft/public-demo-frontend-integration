require 'ostruct'
require_relative './secrets'

class RefreshToken
  def initialize(refresh_token)
    @refresh_token = refresh_token
  end

  def fetch_new_credentials
    response = HTTParty.post(
      Urls.for_env.token_url,
      body: {
        client_id: Secrets.for_env.app_id,
        client_secret: Secrets.for_env.app_secret,
        grant_type: 'refresh_token',
        refresh_token: @refresh_token
      }
    )
    OpenStruct.new(response)
  end
end
