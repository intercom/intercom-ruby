require "spec_helper"

describe Intercom do
  it "has a version number" do
    Intercom::VERSION.must_equal "0.0.1"
  end

  describe "Intercom::User" do
    it "to_hash'es itself" do
      created_at = Time.now
      user = Intercom::User.new("email" => "jim@example.com", :user_id => "12345", :created_at => created_at, :name => "Jim Bob")
      as_hash = user.to_hash
      as_hash["email"].must_equal "jim@example.com"
      as_hash["user_id"].must_equal "12345"
      as_hash["created_at"].must_equal created_at.to_i
      as_hash["name"].must_equal "Jim Bob"
    end

    it "presents created_at and last_impression_at as Date" do
      now = Time.now
      user = Intercom::User.new(:created_at => now, :last_impression_at => now)
      user.created_at.must_be_kind_of Time
      user.created_at.to_s.must_equal now.to_s
      user.last_impression_at.must_be_kind_of Time
      user.last_impression_at.to_s.must_equal now.to_s
    end

    it "is ok on missing methods" do
      user = Intercom::User.new
      user.created_at.must_be_nil
      user.last_impression_at.must_be_nil
      user.email.must_be_nil
      user.social_accounts.must_equal([])
    end

    it "presents a complete user record correctly" do
      user = Intercom::User.new(test_user)
      user.session_count.must_equal 123
      user.social_accounts.size.must_equal 4
      twitter_account = user.social_accounts.first
      twitter_account.must_be_kind_of Intercom::SocialAccount
      twitter_account.type.must_equal "twitter"
      twitter_account.username.must_equal "abc"
      twitter_account.url.must_equal "http://twitter.com/abc"
      user.custom_data["a"]["nested-hash"][2]["deep"].must_equal "very-deep"
    end

    it "has social accounts" do
      user = Intercom::User.new()
      twitter_account = Intercom::SocialAccount.new(:url => "http://twitter.com/abc", "username" => "abc", "type" => "twitter")
      user.social_accounts << twitter_account
      user.social_accounts.size.must_equal 1
      user.social_accounts.first.must_equal twitter_account
      user.to_hash["social_accounts"].must_equal([{"username" => "abc", "url" => "http://twitter.com/abc", "type" => "twitter"}])
    end

    it "allows easy setting of custom data" do
      user = Intercom::User.new()
      user.custom_data["mad"]["stuff"] = [1, 2, 3]
      user.custom_data["mad"]["stuff"].must_equal [1, 2, 3]
    end

    it "takes location data" do
      user = Intercom::User.new
      user.location_data.must_equal({})
      user = Intercom::User.new
      user.location_data["some"] = "thing"
      user.location_data.must_equal({"some" => "thing"})
    end
  end

  describe "API" do
    before do
      Intercom.app_id = "abc123"
      Intercom.secret_key = "super-secret-key"
    end

    it "raises ArgumentError if no app_id or secret_key specified" do
      Intercom.app_id = nil
      Intercom.secret_key = nil
      proc { Intercom.url_for_path("something") }.must_raise ArgumentError, "You must set both Intercom.app_id and Intercom.secret_key to use this client. See https://github.com/intercom/intercom for usage examples."
    end

    it "defaults to https to api.intercom.io" do
      Intercom.url_for_path("some/resource/path").must_equal "https://abc123:super-secret-key@api.intercom.io/api/v1/some/resource/path"
    end

    describe "overriding protocol/hostname" do
      before do
        @protocol = Intercom.protocol
        @hostname = Intercom.hostname
      end

      after do
        Intercom.protocol = @protocol
        Intercom.hostname = @hostname
      end

      it "allows overriding of the endpoint and protocol" do
        Intercom.protocol = "http"
        Intercom.hostname = "localhost:3000"
        Intercom.url_for_path("some/resource/path").must_equal "http://abc123:super-secret-key@localhost:3000/api/v1/some/resource/path"
      end
    end

    describe "/api/v1/users" do
      describe "get" do
        it "fetches a user" do
          Intercom.expects(:get).with("users", {"email" => "bo@example.com"}).returns(test_user)
          user = Intercom::User.find("email" => "bo@example.com")
          user.email.must_equal "bo@example.com"
          user.name.must_equal "Joe Schmoe"
          user.session_count.must_equal 123
        end
      end

      describe "post" do
        it "saves a user" do
          user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242")
          Intercom.expects(:post).with("users", {"email" => "jo@example.com", "user_id" => "i-1224242"})
          user.save
        end

        it "can use User.create for convenience" do
          Intercom.expects(:post).with("users", {"email" => "jo@example.com", "user_id" => "i-1224242"}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
          user = Intercom::User.create("email" => "jo@example.com", :user_id => "i-1224242")
          user.email.must_equal "jo@example.com"
        end

        it "updates the @user with attributes as set by the server" do
          Intercom.expects(:post).with("users", {"email" => "jo@example.com", "user_id" => "i-1224242"}).returns({"email" => "jo@example.com", "user_id" => "i-1224242", "session_count" => 4})
          user = Intercom::User.create("email" => "jo@example.com", :user_id => "i-1224242")
          user.session_count.must_equal 4
        end
      end
    end

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
  end

  describe "correct use of ssl" do
  end
end