require_relative './urls'

class SimpleApi
  BASE_URI = Urls.for_env.api_base
  include HTTParty
  base_uri BASE_URI

  def initialize(base: '/v2', access_token:)
    @base = base
    @access_token = access_token
  end

  def complete_action(id)
    create('activities', { action_id: id })
  end

  # meta

  def create(resource, params={})
    self.class.post(url(resource), body: params.to_json, headers: headers).parsed_response
  end

  def index(resource, params={})
    self.class.get(url(resource), query: params, headers: headers).parsed_response
  end

  def find(resource, id)
    self.class.get(url("#{resource}/#{id}"), headers: headers).parsed_response
  end

  def delete(resource, id)
    self.class.delete(url("#{resource}/#{id}"), headers: headers)
  end

  private

  def url(path)
    "#{@base}/#{path}"
  end

  def headers
    {
      "Authorization" => "Bearer #{@access_token}",
      "Content-Type" => "application/json"
    }
  end
end
