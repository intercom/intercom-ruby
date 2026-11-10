# frozen_string_literal: true

require 'spec_helper'

module Intercom
  describe Client do
    let(:token) { 'my_access_token' }
    let(:client) do
      Client.new(
        token: token,
        handle_rate_limit: true
      )
    end

    it 'should set the base url' do
      _(client.base_url).must_equal('https://api.intercom.io')
    end

    it 'should have handle_rate_limit set' do
      _(client.handle_rate_limit).must_equal(true)
    end

    it 'should be able to change the base url' do
      prev = client.options(Intercom::Client.set_base_url('https://mymockintercom.io'))
      _(client.base_url).must_equal('https://mymockintercom.io')
      client.options(prev)
      _(client.base_url).must_equal('https://api.intercom.io')
    end

    it 'should be able to change the timeouts' do
      prev = client.options(Intercom::Client.set_timeouts(open_timeout: 10, read_timeout: 15))
      _(client.timeouts).must_equal(open_timeout: 10, read_timeout: 15)
      client.options(prev)
      _(client.timeouts).must_equal(open_timeout: 30, read_timeout: 90)
    end

    it 'should be able to change the open timeout individually' do
      prev = client.options(Intercom::Client.set_timeouts(open_timeout: 50))
      _(client.timeouts).must_equal(open_timeout: 50, read_timeout: 90)
      client.options(prev)
      _(client.timeouts).must_equal(open_timeout: 30, read_timeout: 90)
    end

    it 'should be able to change the read timeout individually' do
      prev = client.options(Intercom::Client.set_timeouts(read_timeout: 50))
      _(client.timeouts).must_equal(open_timeout: 30, read_timeout: 50)
      client.options(prev)
      _(client.timeouts).must_equal(open_timeout: 30, read_timeout: 90)
    end

    it 'should raise on nil credentials' do
      _(proc { Client.new(token: nil) }).must_raise MisconfiguredClientError
    end

    describe 'API version' do
      it 'does not set the api version by default' do
        assert_nil(client.api_version)
      end

      it 'allows api version to be provided' do
        _(Client.new(token: token, api_version: '2.0').api_version).must_equal('2.0')
      end

      it 'allows api version to be nil' do
        # matches default behavior, and will honor version set in the Developer Hub
        assert_nil(Client.new(token: token, api_version: nil).api_version)
      end

      it 'allows api version to be Unstable' do
        _(Client.new(token: token, api_version: 'Unstable').api_version).must_equal('Unstable')
      end

      it 'raises on invalid api version' do
        _(proc { Client.new(token: token, api_version: '0.2') }).must_raise MisconfiguredClientError
      end

      it 'raises on empty api version' do
        _(proc { Client.new(token: token, api_version: '') }).must_raise MisconfiguredClientError
      end

      it 'assigns works' do
        stub_request(:any, 'https://api.intercom.io/contacts?id=123').to_return(
          status: [200, 'OK'],
          headers: { 'X-RateLimit-Reset' => Time.now.utc + 10 },
          body: { "test": 'testing' }.to_json
        )

        client.get('/contacts', id: '123')
      end

      it 'sets rate limit details to empty hash' do
        stub_request(:any, "https://api.intercom.io/test").to_raise(StandardError)

        expect { client.get('/test', {}) }.must_raise(StandardError)

        client.rate_limit_details.must_equal({})
      end
    end

    describe 'OAuth clients' do
      it 'supports "token"' do
        client = Client.new(token: 'foo')
        _(client.token).must_equal('foo')
      end
    end
  end
end
