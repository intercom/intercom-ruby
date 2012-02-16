require 'intercom'
require 'minitest/autorun'
require 'mocha'
require 'pry'
IRB = Pry

module Intercom
  def self.mock_rest_client=(client)
    @mock_rest_client = client
  end

  def self.execute_request(method, path, params = {}, headers= {}, payload = nil)
    case method
      when :get then @mock_rest_client.get(path, params)
      when :post then @mock_rest_client.post(path, params, headers, payload)
    end
  end
end

def test_user
  {
      :user_id => 'mysql-id-from-customers-app for eg', # can request by this
      :email => "bo@example.com", # can request by this
      :session_count => 123, # can't be sent - but can get...
      :created_at => 1323422442,
      :last_request_at => 1323422442,
      :name => "Joe Schmoe",
      :social_accounts => {
          "twitter" => [{"url" => "http://twitter.com/abc", "username" => "abc"}, {"username" => "abc2", "url" => "http://twitter.com/abc2"}],
          "facebook" => [{"url" => "http://facebook.com/abc", "username" => "abc", "id" => "1234242"}],
          "quora" => [{"url" => "http://facebook.com/abc", "username" => "abc", "id" => "1234242"}]
      },
      :custom_data => {"a" => 1, "b" => {"nested-hash" => ["ab", 12, {"deep" => "man"}]}}
  }
end