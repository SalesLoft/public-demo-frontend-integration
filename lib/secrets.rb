class Secrets
  def self.for_env(env = ENV.fetch("ENVIRONMENT", "production"))
    new(env)
  end

  def initialize(env)
    @env = env
  end

  def app_id
    ENV.fetch("SALESLOFT_APP_ID_#{@env}")
  end

  def app_secret
    ENV.fetch("SALESLOFT_APP_SECRET_#{@env}")
  end
end
