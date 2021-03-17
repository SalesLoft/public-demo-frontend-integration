class Urls
  ENVS = {
    "dev" => {
      api_base: 'https://localhost.salesloft.com:6443',
      site: 'https://localhost.salesloft.com:6443',
      authorize_url: 'https://localhost.salesloft.com:9898/oauth/authorize',
      token_url: 'https://localhost.salesloft.com:9898/oauth/token'
    },
    "qa" => {
      api_base: 'https://api.qasalesloft.com',
      site: 'https://api.qasalesloft.com',
      authorize_url: 'https://accounts.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts.qasalesloft.com/oauth/token'
    },
    "qa2" => {
      api_base: 'https://api2.qasalesloft.com',
      site: 'https://api2.qasalesloft.com',
      authorize_url: 'https://accounts2.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts2.qasalesloft.com/oauth/token'
    },
    "qa4" => {
      api_base: 'https://api4.qasalesloft.com',
      site: 'https://api4.qasalesloft.com',
      authorize_url: 'https://accounts4.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts4.qasalesloft.com/oauth/token'
    },
    "qa3" => {
      api_base: 'https://api3.qasalesloft.com',
      site: 'https://api3.qasalesloft.com',
      authorize_url: 'https://accounts3.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts3.qasalesloft.com/oauth/token'
    },
    "qa5" => {
      api_base: 'https://api5.qasalesloft.com',
      site: 'https://api5.qasalesloft.com',
      authorize_url: 'https://accounts5.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts5.qasalesloft.com/oauth/token'
    },
    "production" => {
      api_base: 'https://api.salesloft.com',
      site: 'https://api.salesloft.com',
      authorize_url: 'https://accounts.salesloft.com/oauth/authorize',
      token_url: 'https://accounts.salesloft.com/oauth/token'
    }
  }.freeze

  def self.for_env(env = ENV.fetch("ENVIRONMENT", "production"))
    new(env)
  end

  def initialize(env)
    @env = env
  end

  def api_base
    ENVS.fetch(@env)[:api_base]
  end

  def site_url
    ENVS.fetch(@env)[:site]
  end

  def authorize_url
    ENVS.fetch(@env)[:authorize_url]
  end

  def token_url
    ENVS.fetch(@env)[:token_url]
  end
end
