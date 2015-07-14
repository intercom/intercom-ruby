require "spec_helper"

describe "Intercom::Contact" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it 'should be listable' do
    proxy = client.contacts.all
    proxy.resource_name.must_equal 'contacts'
    proxy.finder_url.must_equal '/contacts'
    proxy.resource_class.must_equal Intercom::Contact
  end

  it 'should not throw ArgumentErrors when there are no parameters' do
    client.expects(:post)
    client.contacts.create
  end

  it 'can update a contact with an id' do
    contact = Intercom::Contact.new(:id => "de45ae78gae1289cb")
    client.expects(:put).with("/contacts/de45ae78gae1289cb", {'custom_attributes' => {}})
    client.contacts.save(contact)
  end

  describe 'converting' do
    let(:contact) { Intercom::Contact.from_api(user_id: 'contact_id') }
    let(:user) { Intercom::User.from_api(id: 'user_id') }

    it do
      client.expects(:post).with(
        "/contacts/convert",
        {
          contact: { user_id: contact.user_id },
          user: { 'id' => user.id }
        }
      ).returns(test_user)

      client.contacts.convert(contact, user)
    end
  end

  it "returns a ClientCollectionProxy for all without making any requests" do
    client.expects(:execute_request).never
    all = client.contacts.all
    all.must_be_instance_of(Intercom::ClientCollectionProxy)
  end

  it "deletes a contact" do
    contact = Intercom::Contact.new("id" => "1")
    client.expects(:delete).with("/contacts/1", {}).returns(contact)
    client.contacts.delete(contact)
  end

end
