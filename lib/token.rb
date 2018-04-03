require_relative './refresh_token'

class Token
  def initialize(store)
    @store = store
  end

  def access_token(force_refresh: false)
    @store.transaction do
      expires_at = Time.at(@store[:credentials]["expires_at"])

      if force_refresh || expired?(expires_at) && new_credentials.access_token
        refresh_token
      end

      @store[:credentials]["token"]
    end
  end

  private

  def refresh_token
    if new_credentials.access_token
      @store[:credentials]["token"] = new_credentials.access_token
      @store[:credentials]["refresh_token"] = new_credentials.refresh_token
      @store[:credentials]["expires_at"] = Time.now.to_i + new_credentials.expires_in
      @store[:credentials]
    end
  end

  def expired?(date)
    Time.now > date
  end

  def new_credentials
    @new_credentials ||= RefreshToken.new(@store[:credentials]["refresh_token"]).fetch_new_credentials
  end
end
