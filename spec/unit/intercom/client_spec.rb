require 'spec_helper'

module Intercom
  describe Client do
    let(:app_id) { 'myappid' }
    let(:api_key) { 'myapikey' }
    let(:client) do
      Client.new(
        app_id: app_id,
        api_key: api_key,
        handle_rate_limit: true
      )
    end

    it 'should set the base url' do
      client.base_url.must_equal('https://api.intercom.io')
    end

    it 'should have handle_rate_limit set' do
      _(client.handle_rate_limit).must_equal(true)
    end

    it 'should be able to change the base url' do
      prev = client.options(Intercom::Client.set_base_url('https://mymockintercom.io'))
      client.base_url.must_equal('https://mymockintercom.io')
      client.options(prev)
      client.base_url.must_equal('https://api.intercom.io')
    end

    it 'should be able to change the timeouts' do
      prev = client.options(Intercom::Client.set_timeouts(open_timeout: 10, read_timeout: 15))
      client.timeouts.must_equal(open_timeout: 10, read_timeout: 15)
      client.options(prev)
      client.timeouts.must_equal(open_timeout: 30, read_timeout: 90)
    end

    it 'should be able to change the open timeout individually' do
      prev = client.options(Intercom::Client.set_timeouts(open_timeout: 50))
      client.timeouts.must_equal(open_timeout: 50, read_timeout: 90)
      client.options(prev)
      client.timeouts.must_equal(open_timeout: 30, read_timeout: 90)
    end

    it 'should be able to change the read timeout individually' do
      prev = client.options(Intercom::Client.set_timeouts(read_timeout: 50))
      client.timeouts.must_equal(open_timeout: 30, read_timeout: 50)
      client.options(prev)
      client.timeouts.must_equal(open_timeout: 30, read_timeout: 90)
    end

    it 'should raise on nil credentials' do
      proc { Client.new(app_id: nil, api_key: nil) }.must_raise MisconfiguredClientError
    end

    describe 'API version' do
      it 'does not set the api version by default' do
        assert_nil(client.api_version)
      end

      it 'allows api version to be provided' do
        Client.new(app_id: app_id, api_key: api_key, api_version: '1.0').api_version.must_equal('1.0')
      end

      it 'allows api version to be nil' do
        # matches default behavior, and will honor version set in the Developer Hub
        assert_nil(Client.new(app_id: app_id, api_key: api_key, api_version: nil).api_version)
      end

      it 'raises on invalid api version' do
        proc { Client.new(app_id: app_id, api_key: api_key, api_version: '0.2') }.must_raise MisconfiguredClientError
      end

      it 'raises on empty api version' do
        proc { Client.new(app_id: app_id, api_key: api_key, api_version: '') }.must_raise MisconfiguredClientError
      end

      it "assigns works" do
        stub_request(:any, "https://api.intercom.io/users?id=123").to_return(
          status: [200, "OK"],
          headers: { 'X-RateLimit-Reset' => Time.now.utc + 10 },
          body: { "test": "testing" }.to_json
        )

        client.get("/users", { id: "123" })
      end
    end

    describe 'OAuth clients' do
      it 'supports "token"' do
        client = Client.new(token: 'foo')
        client.username_part.must_equal('foo')
        client.password_part.must_equal('')
      end
    end
  end
end
