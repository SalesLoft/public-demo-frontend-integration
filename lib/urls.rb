class Urls
  ENVS = {
    "qa1" => {
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
    "qa5" => {
      api_base: 'https://api5.qasalesloft.com',
      site: 'https://api5.qasalesloft.com',
      authorize_url: 'https://accounts5.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts5.qasalesloft.com/oauth/token'
    },
    "dev" => {
      api_base: 'https://localhost.salesloft.com:6443',
      site: 'https://localhost.salesloft.com:6443',
      authorize_url: 'https://localhost.salesloft.com:9898/oauth/authorize',
      token_url: 'https://localhost.salesloft.com:9898/oauth/token'
    }
  }.freeze

  def self.for_env(env = ENV.fetch("ENVIRONMENT", "qa1"))
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
