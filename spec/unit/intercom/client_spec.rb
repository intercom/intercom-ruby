require 'spec_helper'

module Intercom
  describe Client do
    let(:app_id) { 'myappid' }
    let(:api_key) { 'myapikey' }
    let(:client) { Client.new(app_id: app_id, api_key: api_key) }

    it 'should set the base url' do
      client.base_url.must_equal('https://api.intercom.io')
    end

    it 'should be able to change the base url' do
      prev = client.options(Intercom::Client.set_base_url('https://mymockintercom.io'))
      client.base_url.must_equal('https://mymockintercom.io')
      client.options(prev)
      client.base_url.must_equal('https://api.intercom.io')
    end

  end
end
