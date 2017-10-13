require 'spec_helper'
require 'ostruct'

WebMock.enable!

describe 'Intercom::Request' do
  it 'raises an error when a html error page rendered' do
    response = OpenStruct.new(:code => 500)
    req = Intercom::Request.new('path/', 'GET')
    proc {req.parse_body('<html>somethjing</html>', response)}.must_raise(Intercom::ServerError)
  end

  it 'raises a RateLimitExceeded error when the response code is 429' do
    response = OpenStruct.new(:code => 429)
    req = Intercom::Request.new('path/', 'GET')
    proc {req.parse_body('<html>somethjing</html>', response)}.must_raise(Intercom::RateLimitExceeded)
  end

  describe 'Intercom::Client' do
    let (:client) { Intercom::Client.new(token: 'foo', handle_rate_limit: true) }
    let (:uri) {"https://api.intercom.io/users"}

    it 'should have handle_rate_limit set' do
       client.handle_rate_limit.must_equal(true)
    end

    it 'should call sleep for rate limit error three times' do
      # Use webmock to mock the HTTP request
      stub_request(:any, uri).\
      to_return(status: [429, "Too Many Requests"], headers: { 'X-RateLimit-Reset' => Time.now.utc + 10 })
      req = Intercom::Request.get(uri, "")
      req.handle_rate_limit=true
      req.expects(:sleep).times(3).with(any_parameters)
      req.execute(target_base_url=uri, username: "ted", secret: "")
    end

    it 'should not call sleep for rate limit error' do
      # Use webmock to mock the HTTP request
      stub_request(:any, uri).\
      to_return(status: [200, "OK"], headers: { 'X-RateLimit-Reset' => Time.now.utc + 10 })
      req = Intercom::Request.get(uri, "")
      req.handle_rate_limit=true
      req.expects(:sleep).never.with(any_parameters)
      req.execute(target_base_url=uri, username: "ted", secret: "")
    end

    it 'should call sleep for rate limit error just once' do
      # Use webmock to mock the HTTP request
      stub_request(:any, uri).\
      to_return(status: [429, "Too Many Requests"], headers: { 'X-RateLimit-Reset' => Time.now.utc + 10 }).\
      then.to_return(status: [200, "OK"])
      req = Intercom::Request.get(uri, "")
      req.handle_rate_limit=true
      req.expects(:sleep).with(any_parameters)
      req.execute(target_base_url=uri, username: "ted", secret: "")
    end

  end

  it 'parse_body returns nil if decoded_body is nil' do
    response = OpenStruct.new(:code => 500)
    req = Intercom::Request.new('path/', 'GET')
    assert_nil(req.parse_body(nil, response))
  end

  it 'parse_body returns nil if the decoded_body is "null"' do
    response = OpenStruct.new(:code => 500)
    req = Intercom::Request.new('path/', 'GET')
    req.parse_body('null', response).must_equal(nil)
  end
end
