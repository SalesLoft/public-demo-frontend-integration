class Store::LocalYaml
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

  def save_unique_id!(unique_id)
    write_property!(:unique_id, unique_id)
  end

  private

  def write_property!(property, value)
    @store.transaction do
      @store[property] = value
    end
  end
end
