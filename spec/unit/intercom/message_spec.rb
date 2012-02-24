require "spec_helper"

describe "/api/v1/messages" do
  it "loads messages for a user" do
    Intercom.expects(:get).with("messages", {"email" => "bo@example.com"}).returns(test_messages)
    messages = Intercom::Message.find_all("email" => "bo@example.com")
    messages.size.must_equal 2
    messages.first.conversation.size.must_equal 3
    messages.first.conversation[0]["rendered_body"].must_equal "<p>Hey Intercom, What is up?</p>\n"
  end

  it "loads message for a thread id" do
    Intercom.expects(:get).with("messages", {"email" => "bo@example.com", "thread_id" => 123}).returns(test_message)
    message = Intercom::Message.find("email" => "bo@example.com", "thread_id" => 123)
    message.conversation.size.must_equal 3
  end

  it "creates a new message" do
    Intercom.expects(:post).with("messages", {"email" => "jo@example.com", "body" => "Hello World"}).returns(test_message)
    message = Intercom::Message.create("email" => "jo@example.com", "body" => "Hello World")
    message.conversation.size.must_equal 3
  end

  it "creates a comment on existing thread" do
    Intercom.expects(:post).with("messages", {"email" => "jo@example.com", "body" => "Hello World", "thread_id" => 123}).returns(test_message)
    message = Intercom::Message.create("email" => "jo@example.com", "body" => "Hello World", "thread_id" => 123)
    message.conversation.size.must_equal 3
  end

  it "marks a thread as read... " do
    Intercom.expects(:put).with("messages", {"read" => true, "email" => "jo@example.com", "thread_id" => 123}).returns(test_message)
    message = Intercom::Message.mark_as_read("email" => "jo@example.com", "thread_id" => 123)
    message.conversation.size.must_equal 3
  end
end