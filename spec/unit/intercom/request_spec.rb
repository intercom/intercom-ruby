require 'spec_helper'
require 'ostruct'

WebMock.enable!

describe 'Intercom::Request', '#execute' do
  let(:uri) {"https://api.intercom.io/users"}
  let(:req) { Intercom::Request.get(uri, {}) }
  let(:default_body) { { data: "test" }.to_json }

  def execute!
    req.execute(uri, token: 'test-token')
  end

  it 'should call sleep for rate limit error three times and raise a rate limit error otherwise' do
    stub_request(:any, uri).to_return(
      status: [429, "Too Many Requests"],
      headers: { 'X-RateLimit-Reset' => (Time.now.utc + 10).to_i.to_s },
      body: default_body
    )

    req.handle_rate_limit=true

    req.expects(:sleep).times(3).with(any_parameters)

    expect { execute! }.must_raise(Intercom::RateLimitExceeded)
  end

  it 'should not call sleep for rate limit error' do
    stub_request(:any, uri).to_return(
      status: [200, "OK"],
      headers: { 'X-RateLimit-Reset' => Time.now.utc + 10 },
      body: default_body
    )

    req.handle_rate_limit=true
    req.expects(:sleep).never.with(any_parameters)

    execute!
  end

  it 'should call sleep for rate limit error just once' do
    stub_request(:any, uri).to_return(
      status: [429, "Too Many Requests"],
      headers: { 'X-RateLimit-Reset' => (Time.now.utc + 10).to_i.to_s },
    ).then.to_return(status: [200, "OK"], body: default_body)

    req.handle_rate_limit=true
    req.expects(:sleep).with(any_parameters)

    execute!
  end

  it 'should not call sleep for rate limit if reset is not received' do
    stub_request(:any, uri).to_return(
      status: [429, "Too Many Requests"],
    ).then.to_return(status: [200, "OK"], body: default_body)

    req.handle_rate_limit=true
    req.expects(:sleep).never.with(any_parameters)

    execute!
  end

  it 'should not sleep if rate limit reset time has passed' do
    stub_request(:any, uri).to_return(
      status: [429, "Too Many Requests"],
      headers: { 'X-RateLimit-Reset' => Time.parse("February 25 2010").utc.to_i.to_s },
      body: default_body
    ).then.to_return(status: [200, "OK"], body: default_body)

    req.handle_rate_limit=true
    req.expects(:sleep).never.with(any_parameters)

    execute!
  end

  it 'handles an empty body gracefully' do
    stub_request(:any, uri).to_return(
      status: 200,
      body: nil
    )

    assert_nil(execute!)
  end

  describe 'HTTP error handling' do
    it 'raises an error when the response is successful but the body is not JSON' do
      stub_request(:any, uri).to_return(
        status: 200,
        body: '<html>something</html>'
      )

      expect { execute! }.must_raise(Intercom::UnexpectedResponseError)
    end

    it 'raises an error when an html error page rendered' do
      stub_request(:any, uri).to_return(
        status: 500,
        body: '<html>something</html>'
      )

      expect { execute! }.must_raise(Intercom::ServerError)
    end

    it 'raises an error if the decoded_body is "null"' do
      stub_request(:any, uri).to_return(
        status: 500,
        body: 'null'
      )

      expect { execute! }.must_raise(Intercom::ServerError)
    end

    it 'raises a RateLimitExceeded error when the response code is 429' do
      stub_request(:any, uri).to_return(
        status: 429,
        body: 'null'
      )

      expect { execute! }.must_raise(Intercom::RateLimitExceeded)
    end

    it 'raises a GatewayTimeoutError error when the response code is 504' do
      stub_request(:any, uri).to_return(
        status: 504,
        body: '<html> <head><title>504 Gateway Time-out</title></head> <body bgcolor="white"> <center><h1>504 Gateway Time-out</h1></center> </body> </html>'
      )

      expect { execute! }.must_raise(Intercom::GatewayTimeoutError)
    end
  end

  describe "application error handling" do
    let(:uri) {"https://api.intercom.io/conversations/reply"}
    let(:req) { Intercom::Request.put(uri, {}) }

    it 'should raise ResourceNotUniqueError error on resource_conflict code' do
      stub_request(:put, uri).to_return(
        status: [409, "Resource Already Exists"],
        headers: { 'X-RateLimit-Reset' => (Time.now.utc + 10).to_i.to_s },
        body: { type: "error.list", errors: [ code: "resource_conflict" ] }.to_json
      )

      expect { execute! }.must_raise(Intercom::ResourceNotUniqueError)
    end

    it 'should raise ApiVersionInvalid error on intercom_version_invalid code' do
      stub_request(:put, uri).to_return(
        status: [400, "Bad Request"],
        headers: { 'X-RateLimit-Reset' => (Time.now.utc + 10).to_i.to_s },
        body: { type: "error.list", errors: [ code: "intercom_version_invalid" ] }.to_json
      )

      expect { execute! }.must_raise(Intercom::ApiVersionInvalid)
    end

    it 'should raise ResourceNotFound error on company_not_found code' do
      stub_request(:put, uri).to_return(
        status: [404, "Not Found"],
        headers: { 'X-RateLimit-Reset' => (Time.now.utc + 10).to_i.to_s },
        body: { type: "error.list", errors: [ code: "company_not_found" ] }.to_json
      )

      expect { execute! }.must_raise(Intercom::ResourceNotFound)
    end
  end
end
