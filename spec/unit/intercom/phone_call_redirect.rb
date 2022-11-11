require 'spec_helper'

describe "Intercom::PhoneCallRedirect" do
  let(:client) { Intercom::Client.new(token: 'token') }

  it "creates a phone redirect" do
    
    client.expects(:post).with("/phone_call_redirect", {phone_number: "+353871234567"})
    client.phone_call_redirect.create(phone_number: "+353871234567")
  end

end
