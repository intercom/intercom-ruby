require 'spec_helper'

describe 'Intercom::Visitor' do
  let (:client) { Intercom::Client.new(token: 'token') }

  it 'can update a visitor with an id' do
    visitor = Intercom::Visitor.new(:id => 'de45ae78gae1289cb')
    client.expects(:put).with('/visitors/de45ae78gae1289cb', 'custom_attributes' => {})
    client.visitors.save(visitor)
  end

  it 'can get a visitor' do
    visitor = Intercom::Visitor.new(:id => 'de45ae78gae1289cb')
    client.expects(:get).with('/visitors/de45ae78gae1289cb', {}).returns(test_visitor)
    client.visitors.find(id: visitor.id)
  end

  describe 'converting' do
    let(:visitor) { Intercom::Visitor.from_api(user_id: 'visitor_id') }
    let(:user) { Intercom::Contact.from_api(id: 'user_id', role: 'user') }

    it 'visitor to user' do
      client.expects(:post).with(
        '/visitors/convert',
        visitor: { user_id: visitor.user_id },
        user: { 'id' => user.id },
        type: 'user'
      ).returns(test_contact)

      client.visitors.convert(visitor, user)
    end

    it 'visitor to lead' do
      client.expects(:post).with(
        '/visitors/convert',
        visitor: { user_id: visitor.user_id },
        type: 'lead'
      ).returns(test_contact(role: 'lead'))

      client.visitors.convert(visitor)
    end
  end

  it 'deletes a visitor' do
    visitor = Intercom::Visitor.new('id' => '1')
    client.expects(:delete).with('/visitors/1', {}).returns(visitor)
    client.visitors.delete(visitor)
  end
end
