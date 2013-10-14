require "spec_helper"
require 'fakeweb'

describe "api.intercom.io dummy data requests" do
  before :each do
    Intercom.app_id = "dummy-app-id"
    Intercom.api_key = "dummy-secret-key"
    Intercom.endpoint = "https://api.intercom.io"
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

  it "should create some notes" do
    note = Intercom::Note.create(:body => "This is a note", :email => "somebody@example.com")
    note.html.must_equal "<p>This is a note</p>"
    note.user.email.must_equal "somebody@example.com"
  end

  it "should failover to good endpoint when first one is un-reachable" do
    Intercom.endpoints = unshuffleable_array(["http://127.0.0.7", "https://api.intercom.io"])
    user = Intercom::User.find(:email => "somebody@example.com")
    user.name.must_equal "Somebody"
  end

  it "should raise error when endpoint(s) are un-reachable" do
    [
      ["502", "Bad Gateway"],
      ["503", "Service Unavailable"]
    ].each do |status|
      FakeWeb.register_uri(:get, %r|example\.com/|, :status => status)
      Intercom.endpoints = ["http://example.com"]
      proc { Intercom::User.find(:email => "somebody@example.com")}.must_raise Intercom::ServiceUnavailableError
      Intercom.endpoints = ["http://example.com", "http://api.example.com"]
      proc { Intercom::User.find(:email => "somebody@example.com")}.must_raise Intercom::ServiceUnavailableError
    end
  end
end
