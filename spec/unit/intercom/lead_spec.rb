# frozen_string_literal: true

require 'spec_helper'

describe 'Intercom::Lead' do
  let (:client) { Intercom::Client.new(token: 'token') }

  it 'should be listable' do
    proxy = client.deprecated__leads.all
    _(proxy.resource_name).must_equal 'contacts'
    _(proxy.resource_class).must_equal Intercom::Lead
  end

  it 'should not throw ArgumentErrors when there are no parameters' do
    client.expects(:post)
    client.deprecated__leads.create
  end

  it 'can update a lead with an id' do
    lead = Intercom::Lead.new(id: 'de45ae78gae1289cb')
    client.expects(:put).with('/contacts/de45ae78gae1289cb', 'custom_attributes' => {})
    client.deprecated__leads.save(lead)
  end

  describe 'converting' do
    let(:lead) { Intercom::Lead.from_api(user_id: 'contact_id') }
    let(:user) { Intercom::User.from_api(id: 'user_id') }

    it do
      client.expects(:post).with(
        '/contacts/convert',
        contact: { user_id: lead.user_id },
        user: { 'id' => user.id }
      ).returns(test_user)

      client.deprecated__leads.convert(lead, user)
    end
  end

  it 'returns a DeprecatedLeadsCollectionProxy for all without making any requests' do
    client.expects(:execute_request).never
    all = client.deprecated__leads.all
    _(all).must_be_instance_of(Intercom::DeprecatedLeadsCollectionProxy)
  end

  it 'deletes a lead' do
    lead = Intercom::Lead.new('id' => '1')
    client.expects(:delete).with('/contacts/1', {}).returns(lead)
    client.deprecated__leads.delete(lead)
  end

  it 'sends a request for a hard deletion' do
    lead = Intercom::Lead.new('id' => '1')
    client.expects(:post).with('/user_delete_requests', intercom_user_id: '1').returns(id: lead.id)
    client.deprecated__leads.request_hard_delete(lead)
  end
end
