require 'intercom'
require 'minitest/autorun'

describe "api.intercom.io dummy data requests" do
  before :each do
    Intercom.app_id = "dummy-app-id"
    Intercom.api_key = "dummy-secret-key"
  end

  it "should get all user" do
    Intercom::User.all.count.must_be :>, 0
  end

  it "should get a user" do
    user = Intercom::User.find(:email => "somebody@example.com")
    user.name.must_equal "Somebody"
  end

  it "not found... " do
    proc { Intercom::User.find(:email => "not-found@example.com") }.must_raise Intercom::ResourceNotFound
  end

  it "server error" do
    proc { Intercom::User.find(:email => "server-error@example.com") }.must_raise Intercom::ServerError
  end

  it "authentication failure with bad api key" do
    Intercom.app_id = "bad-app-id"
    Intercom.api_key = "bad-secret-key"
    proc { Intercom::User.find(:email => "not-found@example.com") }.must_raise Intercom::AuthenticationError
  end

  it "should find_all messages for a user" do
    message_thread = Intercom::MessageThread.find_all(:email => "somebody@example.com").first
    %w(thread_id read messages created_at updated_at created_by_user).each do |expected|
      message_thread.send(expected).wont_be_nil
    end
  end

  it "should mark message_thread as read" do
    message_thread = Intercom::MessageThread.find_all(:email => "somebody@example.com").first
    message_thread.mark_as_read!
  end

  it "should create some impression" do
    impression = Intercom::Impression.create(:email => 'somebody@example.com')
    impression.unread_messages.must_be :>, 0
    impression.email.must_equal 'somebody@example.com'
  end
end