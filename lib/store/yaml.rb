class Store::Yaml
  def initialize(tenant_id, integration_id)
    @store = YAML::Store.new("credentials.store.#{tenant_id}.#{integration_id}")
  end

  def get_property(property)
    @store.transaction { @store[property] }
  end

  def save_credentials!(credentials)
    write_property!(:credentials, credentials.to_h)
  end

  def save_secret!(secret)
    write_property!(:secret, secret)
  end

  private

  def write_property!(property, value)
    @store.transaction do
      @store[property] = value
    end
  end
end
