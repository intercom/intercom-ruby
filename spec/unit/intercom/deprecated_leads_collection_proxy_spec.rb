# frozen_string_literal: true

require 'spec_helper'

describe Intercom::ClientCollectionProxy do
  let(:client) { Intercom::Client.new(token: 'token') }
  let(:lead_json) do
    { 'type' => 'contact.list', 'contacts' => [{ 'type' => 'contact', 'id' => 'id' }] }
  end

  it 'stops iterating if no next link' do
    client.expects(:get).with('/contacts', {}).returns(lead_json)
    client.deprecated__leads.all.each do |company|
      _(company.class).must_equal Intercom::Lead
    end
  end
end
