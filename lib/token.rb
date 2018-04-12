require_relative './refresh_token'

class Token
  def initialize(store)
    @store = store
  end

  def access_token(force_refresh: false)
    expires_at = Time.at(Hash(@store.get_property(:credentials))["expires_at"])

    if force_refresh || expired?(expires_at) && new_credentials.access_token
      refresh_token
    end

    Hash(@store.get_property(:credentials))["token"]
  end

  private

  def refresh_token
    if new_credentials.access_token
      credentials = Hash(@store.get_property(:credentials))
      credentials["token"] = new_credentials.access_token
      credentials["refresh_token"] = new_credentials.refresh_token
      credentials["expires_at"] = Time.now.to_i + new_credentials.expires_in
      @store.save_credentials!(credentials)
      credentials
    end
  end

  def expired?(date)
    Time.now > date
  end

  def new_credentials
    @new_credentials ||= RefreshToken.new(Hash(@store.get_property(:credentials))["refresh_token"]).fetch_new_credentials
  end
end
