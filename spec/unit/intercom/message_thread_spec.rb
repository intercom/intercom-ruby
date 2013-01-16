require "spec_helper"

describe "/v1/messages_threads" do
  it "loads messages for a user" do
    Intercom.expects(:get).with("users/message_threads", {"email" => "bo@example.com"}).returns(test_messages)
    message_threads = Intercom::MessageThread.find_all("email" => "bo@example.com")
    message_threads.size.must_equal 2
    message_threads.first.messages.size.must_equal 3
    message_threads.first.messages[0].html.must_equal "<p>Hey Intercom, What is up?</p>\n"
  end

  it "loads message for a thread id" do
    Intercom.expects(:get).with("users/message_threads", {"email" => "bo@example.com", "thread_id" => 123}).returns(test_message)
    message_thread = Intercom::MessageThread.find("email" => "bo@example.com", "thread_id" => 123)
    message_thread.messages.size.must_equal 3
  end

  it "creates a new message" do
    Intercom.expects(:post).with("users/message_threads", {"email" => "jo@example.com", "body" => "Hello World"}).returns(test_message)
    message_thread = Intercom::MessageThread.create("email" => "jo@example.com", "body" => "Hello World")
    message_thread.messages.size.must_equal 3
  end

  it "creates a comment on existing thread" do
    Intercom.expects(:post).with("users/message_threads", {"email" => "jo@example.com", "body" => "Hello World", "thread_id" => 123}).returns(test_message)
    message_thread = Intercom::MessageThread.create("email" => "jo@example.com", "body" => "Hello World", "thread_id" => 123)
    message_thread.messages.size.must_equal 3
  end

  it "marks a thread as read... " do
    Intercom.expects(:put).with("users/message_threads", {"read" => true, "email" => "jo@example.com", "thread_id" => 123}).returns(test_message)
    message_thread = Intercom::MessageThread.mark_as_read("email" => "jo@example.com", "thread_id" => 123)
    message_thread.messages.size.must_equal 3
  end

  it "sets/gets allowed keys" do
    params = {"email" => "me@example.com", :user_id => "abc123", "thread_id" => "123", "body" => "hello world", "read" => true, "url" => "http://example.com"}
    message_thread = Intercom::MessageThread.new(params)
    message_thread.to_hash.keys.sort.must_equal params.keys.map(&:to_s).sort
    params.keys.each do |key|
      message_thread.send(key).must_equal params[key]
    end
  end

  it "should do automatic unwrapping of the timestamp " do
    message_thread = Intercom::MessageThread.from_api(test_message)
    message_thread.created_at.to_s.must_equal Time.at(test_message['created_at']).to_s
    message_thread.updated_at.to_s.must_equal Time.at(test_message['updated_at']).to_s
  end

  describe "messages" do
    it "has nice interface onto messages thread." do
      message_thread = Intercom::MessageThread.from_api(test_message)
      message_thread.messages.size.must_equal 3
      message_thread.messages[0].created_at.to_s.must_equal Time.at(test_message['messages'][0]['created_at']).to_s
      message_thread.messages[0].html.must_equal test_message['messages'][0]['html']
      from_0 = test_message['messages'][0]['from']
      message_thread.messages[0].from.email.must_equal from_0['email']
      message_thread.messages[0].from.name.must_equal from_0['name']
      message_thread.messages[0].from.admin?.must_equal from_0['is_admin']
      message_thread.messages[0].from.user_id.must_equal from_0['user_id']
      message_thread.messages[0].from.avatar_path_50.must_equal nil

      message_thread.messages[1].created_at.must_equal Time.at(test_message['messages'][1]['created_at'])
      message_thread.messages[1].html.must_equal test_message['messages'][1]['html']
      from_1 = test_message['messages'][1]['from']
      message_thread.messages[1].from.email.must_equal from_1['email']
      message_thread.messages[1].from.name.must_equal from_1['name']
      message_thread.messages[1].from.admin?.must_equal from_1['is_admin']
      message_thread.messages[1].from.user_id.must_equal from_1['user_id']
      message_thread.messages[1].from.avatar_path_50.must_equal from_1['avatar_path_50']
    end
  end
end