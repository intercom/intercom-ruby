require "spec_helper"

describe "Intercom::Contact" do
  it 'should not throw ArgumentErrors when there are no parameters' do
    Intercom.expects(:post)
    Intercom::Contact.create
  end

  describe 'converting' do
    let(:contact) { Intercom::Contact.from_api(user_id: 'contact_id') }
    let(:user) { Intercom::User.from_api(id: 'user_id') }

    it do
      Intercom.expects(:post).with(
        "/contacts/convert",
        {
          contact: { user_id: contact.user_id },
          user: user.identity_hash
        }
      ).returns(test_user)

      contact.convert(user)
    end
  end
end
