class Store::Redis
  def initialize(tenant_id, integration_id)
    @key = "DemoFrontendIntegration::credentials.store.#{tenant_id}.#{integration_id}"
    @redis = Redis.new(url: ENV.fetch("REDIS_URL", nil))
  end

  def get_property(property)
    hash = JSON.parse(@redis.get(@key) || "{}")
    hash[property.to_s]
  end

  def save_credentials!(credentials)
    write_property!(:credentials, credentials.to_h)
  end

  def save_secret!(secret)
    write_property!(:secret, secret)
  end

  private

  def write_property!(property, value)
    hash = JSON.parse(@redis.get(@key) || "{}")
    hash[property.to_s] = value
    @redis.set(@key, hash.to_json)
  end
end
