require "spec_helper"

describe Intercom do
  it "has a version number" do
    Intercom::VERSION.must_equal "0.0.2"
  end

  describe "Intercom::IntercomObject" do
    describe "requires_params" do
      it "raises if they are missing" do
        params = {"a" => 1, "b" => 2}
        Intercom::IntercomObject.requires_parameters(params, %W(a b))
        expected_message = "Missing required parameters (c)."
        proc { Intercom::IntercomObject.requires_parameters(params, %W(a b c)) }.must_raise ArgumentError, expected_message
        capture_exception { Intercom::IntercomObject.requires_parameters(params, %W(a b c)) }.message.must_equal expected_message
      end
    end

    describe "allows_params" do
      it "raises if there are extra ones" do
        params = {"a" => 1, "b" => 2}
        Intercom::IntercomObject.allows_parameters(params, %W(a b))
        expected_message = "Unexpected parameters (b). Only allowed parameters for this operation are (email, user_id, a)."
        proc { Intercom::IntercomObject.allows_parameters(params, %W(a)) }.must_raise ArgumentError, expected_message
        capture_exception { Intercom::IntercomObject.allows_parameters(params, %W(a)) }.message.must_equal expected_message
      end

      it "it ignores email and user_id since they are always allowed" do
        params = {"a" => 1, "b" => 2, "email" => "ddd@ddd.ddd", "user_id" => "123abc"}
        Intercom::IntercomObject.allows_parameters(params, %W(a b))
        Intercom::IntercomObject.allows_parameters(params, %W(a b email user_id))
      end
    end
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
      user.social_profiles.must_equal([])
    end

    it "presents a complete user record correctly" do
      user = Intercom::User.new(test_user)
      user.session_count.must_equal 123
      user.social_profiles.size.must_equal 4
      twitter_account = user.social_profiles.first
      twitter_account.must_be_kind_of Intercom::SocialProfile
      twitter_account.type.must_equal "twitter"
      twitter_account.username.must_equal "abc"
      twitter_account.url.must_equal "http://twitter.com/abc"
      user.custom_data["a"]["nested-hash"][2]["deep"].must_equal "very-deep"
    end

    it "has read-only social accounts" do
      user = Intercom::User.new(:social_profiles => [:url => "http://twitter.com/abc", "username" => "abc", "type" => "twitter"])
      user.social_profiles.size.must_equal 1
      twitter = user.social_profiles.first
      twitter.type.must_equal "twitter"
      twitter.url.must_equal "http://twitter.com/abc"
      twitter.username.must_equal "abc"
      user.to_hash["social_profiles"].must_equal nil
      proc { user.social_profiles << "a" }.must_raise RuntimeError, "can't modify frozen array"
      proc { Intercom::User.new.social_profiles << "a" }.must_raise RuntimeError, "can't modify frozen array"
    end

    it "fucking works" do
      assert_raises(RuntimeError, "adadax") do
        raise RuntimeError.new("adada")
      end
      proc { raise RuntimeError.new("adada") }.must_raise RuntimeError, "adadax"
    end

    it "has read-only location data" do
      Intercom::User.new.location_data.must_equal({})
      user = Intercom::User.new(:location_data => {"city" => "Dublin"})
      user.location_data.must_equal({"city" => "Dublin"})
      proc { user.location_data["change"] = "123" }.must_raise RuntimeError, "can't modify frozen hash"
      user.to_hash["location_data"].must_equal nil
    end

    it "allows easy setting of custom data" do
      now = Time.now
      user = Intercom::User.new()
      user.custom_data["mad"] = 123
      user.custom_data["other"] = now
      user.custom_data["thing"] = "yay"
      user.to_hash["custom_data"].must_equal "mad" => 123, "other" => now, "thing" => "yay"
    end

    it "rejects nested data structures in custom_data" do
      user = Intercom::User.new()
      proc { user.custom_data["thing"] = [1] }.must_raise ArgumentError
      proc { user.custom_data["thing"] = {1 => 2} }.must_raise ArgumentError
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

    it "checks for email or user id" do
      proc { Intercom.require_email_or_user_id("else") }.must_raise ArgumentError, "Expected params Hash, got String"
      proc { Intercom.require_email_or_user_id(:something => "else") }.must_raise ArgumentError, "Either email or user_id must be specified"
      proc { Intercom.get("users", :something => "else") }.must_raise ArgumentError, "Either email or user_id must be specified"
      proc { Intercom.put("users", :something => "else") }.must_raise ArgumentError, "Either email or user_id must be specified"
      proc { Intercom.post("users", :something => "else") }.must_raise ArgumentError, "Either email or user_id must be specified"
      Intercom.require_email_or_user_id(:email => "bob@example.com", :something => "else")
      Intercom.require_email_or_user_id("email" => "bob@example.com", :something => "else")
      Intercom.require_email_or_user_id(:user_id => "123")
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

    describe "/api/v1/impressions" do
      it "creates a good impression" do
        Intercom.expects(:post).with("impressions", {"email" => "jo@example.com", "location" => "/some/path/in/my/app"}).returns({"unread_messages" => 10})
        impression = Intercom::Impression.create("email" => "jo@example.com", "location" => "/some/path/in/my/app")
        impression.unread_messages.must_equal 10
      end
    end
  end
end