require "spec_helper"
require 'fakeweb'

describe "api.intercom.io dummy data requests" do
  before :each do
    Intercom.app_id = "some-app-id"
    Intercom.api_key = "some-secret-key"
    Intercom.endpoint = "https://intercom.example.com"
    FakeWeb.clean_registry
  end

  def fixture(name)
    File.read(File.expand_path("../fixtures/#{name}.json", __FILE__))
  end

  it "should get all user" do
    FakeWeb.register_uri(:get, %r|v1/users|, :body => fixture('v1-users'))
    Intercom::User.all.count.must_be :>, 0
  end

  it "should get a user" do
    FakeWeb.register_uri(:get, %r(v1/users\?email=), :body => fixture('v1-user'))
    user = Intercom::User.find(:email => "somebody@example.com")
    user.name.must_equal "Somebody"
  end

  it "not found... " do
    FakeWeb.register_uri(:get, %r(v1/users\?email=not-found), :status => [404, "Not Found"])
    proc { Intercom::User.find(:email => "not-found@example.com") }.must_raise Intercom::ResourceNotFound
  end

  it "server error" do
    FakeWeb.register_uri(:get, %r(v1/users\?email=server-error), :status => [500, "Oh Noes"])
    proc { Intercom::User.find(:email => "server-error@example.com") }.must_raise Intercom::ServerError
  end

  it "authentication failure with bad api key" do
    FakeWeb.register_uri(:get, %r(v1/users\?email=authentication-error), :status => [401, "Authentication Error"])
    Intercom.app_id = "bad-app-id"
    Intercom.api_key = "bad-secret-key"
    proc { Intercom::User.find(:email => "authentication-error@example.com") }.must_raise Intercom::AuthenticationError
  end

  it "should find_all messages for a user" do
    FakeWeb.register_uri(:get, %r(v1/users/message_threads\?email=somebody), :body => fixture('v1-users-message_threads'))
    message_thread = Intercom::MessageThread.find_all(:email => "somebody@example.com").first
    %w(thread_id read messages created_at updated_at created_by_user).each do |expected|
      message_thread.send(expected).wont_be_nil
    end
  end

  it "should mark message_thread as read" do
    FakeWeb.register_uri(:get, %r(v1/users/message_threads\?email=somebody), :body => fixture('v1-users-message_threads'))
    FakeWeb.register_uri(:put, %r(v1/users/message_threads), :body => fixture('v1-users-message_thread'))
    message_thread = Intercom::MessageThread.find_all(:email => "somebody@example.com").first
    message_thread.mark_as_read!
  end

  it "should create some impression" do
    FakeWeb.register_uri(:post, %r(v1/users/impressions), :body => fixture('v1-users-impression'))
    impression = Intercom::Impression.create(:email => 'somebody@example.com')
    impression.unread_messages.must_be :>, 0
    impression.email.must_equal 'somebody@example.com'
  end

  it "should create some notes" do
    FakeWeb.register_uri(:post, %r(v1/users/notes), :body => fixture('v1-users-note'))
    note = Intercom::Note.create(:body => "This is a note", :email => "somebody@example.com")
    note.html.must_equal "<p>This is a note</p>"
    note.user.email.must_equal "somebody@example.com"
  end


  it "should failover to good endpoint when first one is un-reachable" do
    FakeWeb.allow_net_connect = %r(127.0.0.7)
    FakeWeb.register_uri(:get, %r(api.intercom.io/v1/users), :body => fixture('v1-user'))
    Intercom.endpoints = unshuffleable_array(["http://127.0.0.7", "https://api.intercom.io"])
    user = Intercom::User.find(:email => "somebody@example.com")
    user.name.must_equal "Somebody"
  end

  it "should raise error when endpoint(s) are un-reachable" do
    FakeWeb.register_uri(:get, %r|example\.com/|, :status => ["503", "Service Unavailable"])
    Intercom.endpoints = ["http://example.com"]
    proc { Intercom::User.find(:email => "somebody@example.com")}.must_raise Intercom::ServiceUnavailableError
    Intercom.endpoints = ["http://example.com", "http://api.example.com"]
    proc { Intercom::User.find(:email => "somebody@example.com")}.must_raise Intercom::ServiceUnavailableError
  end

  it "should raise gateway error when the request returns a 502" do
    FakeWeb.register_uri(:get, %r|example\.com/|, :status => ["502", "Bad Gateway"])
    Intercom.endpoints = ["http://example.com"]
    proc { Intercom::User.find(:email => "somebody@example.com")}.must_raise Intercom::BadGatewayError
    Intercom.endpoints = ["http://example.com", "http://api.example.com"]
    proc { Intercom::User.find(:email => "somebody@example.com")}.must_raise Intercom::BadGatewayError

  end
end