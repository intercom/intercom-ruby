require "intercom/version"
require "rest_client"
require 'json'

module Intercom
  def self.app_id=(app_id)
    @app_id = app_id
  end

  def self.secret_key=(secret_key)
    @secret_key = secret_key
  end

  def self.protocol
    "https"
  end

  def self.hostname
    "api.intercom.io"
  end

  def self.execute_request(method, path, params = {}, headers = {}, payload = nil)
    url = "https://#{@app_id}:#{@secret_key}@api.intercom.io/v1/#{path}"
    args = {
        :method => method,
        :url => url,
        :headers => {:params => params}.merge(headers),
        :open_timeout => 10,
        :payload => payload,
        :timeout => 30
    }
    RestClient::Request.execute(args)
  end

  class User
    def initialize(response)
      @response = response
    end

    def self.find(params)
      response = Intercom.execute_request(:get, "users", params)
      User.new(response)
    end

    def save
      Intercom.execute_request(:post, "users", {}, {:content_type => :json}, {"email" => "bo@example.com"}.to_json)
    end

    def method_missing(method, *args, &block)
      @response[method.to_sym]
    end
  end
end
