require "spec_helper"

describe "Intercom::Contact" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it 'should not throw ArgumentErrors when there are no parameters' do
    client.expects(:post)
    client.contacts.create
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
end
