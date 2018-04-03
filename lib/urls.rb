class Urls
  ENVS = {
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
