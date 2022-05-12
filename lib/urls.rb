class Urls
  ENVS = {
    "dev" => {
      api_base: 'https://localhost.salesloft.com:7443',
      site: 'https://localhost.salesloft.com:7443',
      authorize_url: 'https://accounts.devsalesloft.com/oauth/authorize',
      token_url: 'https://accounts.devsalesloft.com/oauth/token'
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
    "qa3" => {
      api_base: 'https://api3.qasalesloft.com',
      site: 'https://api3.qasalesloft.com',
      authorize_url: 'https://accounts3.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts3.qasalesloft.com/oauth/token'
    },
    "qa4" => {
      api_base: 'https://api4.qasalesloft.com',
      site: 'https://api4.qasalesloft.com',
      authorize_url: 'https://accounts4.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts4.qasalesloft.com/oauth/token'
    },
    "qa5" => {
      api_base: 'https://api5.qasalesloft.com',
      site: 'https://api5.qasalesloft.com',
      authorize_url: 'https://accounts5.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts5.qasalesloft.com/oauth/token'
    },
    "qa6" => {
      api_base: 'https://api6.qasalesloft.com',
      site: 'https://api6.qasalesloft.com',
      authorize_url: 'https://accounts6.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts6.qasalesloft.com/oauth/token'
    },
    "qa7" => {
      api_base: 'https://api7.qasalesloft.com',
      site: 'https://api7.qasalesloft.com',
      authorize_url: 'https://accounts7.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts7.qasalesloft.com/oauth/token'
    },
    "qa8" => {
      api_base: 'https://api8.qasalesloft.com',
      site: 'https://api8.qasalesloft.com',
      authorize_url: 'https://accounts8.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts8.qasalesloft.com/oauth/token'
    },
    "qa9" => {
      api_base: 'https://api9.qasalesloft.com',
      site: 'https://api9.qasalesloft.com',
      authorize_url: 'https://accounts9.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts9.qasalesloft.com/oauth/token'
    },
    "qa10" => {
      api_base: 'https://api10.qasalesloft.com',
      site: 'https://api10.qasalesloft.com',
      authorize_url: 'https://accounts10.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts10.qasalesloft.com/oauth/token'
    },
    "qa11" => {
      api_base: 'https://api11.qasalesloft.com',
      site: 'https://api11.qasalesloft.com',
      authorize_url: 'https://accounts11.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts11.qasalesloft.com/oauth/token'
    },
    "qa12" => {
      api_base: 'https://api12.qasalesloft.com',
      site: 'https://api12.qasalesloft.com',
      authorize_url: 'https://accounts12.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts12.qasalesloft.com/oauth/token'
    },
    "qa13" => {
      api_base: 'https://api13.qasalesloft.com',
      site: 'https://api13.qasalesloft.com',
      authorize_url: 'https://accounts13.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts13.qasalesloft.com/oauth/token'
    },
    "qa14" => {
      api_base: 'https://api14.qasalesloft.com',
      site: 'https://api14.qasalesloft.com',
      authorize_url: 'https://accounts14.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts14.qasalesloft.com/oauth/token'
    },
    "qa15" => {
      api_base: 'https://api15.qasalesloft.com',
      site: 'https://api15.qasalesloft.com',
      authorize_url: 'https://accounts15.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts15.qasalesloft.com/oauth/token'
    },
    "qa16" => {
      api_base: 'https://api16.qasalesloft.com',
      site: 'https://api16.qasalesloft.com',
      authorize_url: 'https://accounts16.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts16.qasalesloft.com/oauth/token'
    },
    "qa17" => {
      api_base: 'https://api17.qasalesloft.com',
      site: 'https://api17.qasalesloft.com',
      authorize_url: 'https://accounts17.qasalesloft.com/oauth/authorize',
      token_url: 'https://accounts17.qasalesloft.com/oauth/token'
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
