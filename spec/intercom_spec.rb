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
      user.social_accounts.must_equal({})
      user.social_accounts["twitter"].must_equal []
    end

    it "presents a complete user record correctly" do
      user = Intercom::User.new(test_user)
      user.session_count.must_equal 123
      user.social_accounts["twitter"].size.must_equal 2
      twitter_account = user.social_accounts["twitter"].first
      twitter_account.must_be_kind_of Intercom::SocialAccount
      twitter_account.username.must_equal "abc"
      twitter_account.url.must_equal "http://twitter.com/abc"
      user.custom_data["a"]["nested-hash"][2]["deep"].must_equal "very-deep"
    end

    it "has social accounts" do
      user = Intercom::User.new()
      twitter_account = Intercom::SocialAccount.new(:url => "http://twitter.com/abc", "username" => "abc")
      user.social_accounts["twitter"] << twitter_account
      user.social_accounts["twitter"].size.must_equal 1
      user.social_accounts["twitter"].first.must_equal twitter_account
      user.to_hash["social_accounts"]["twitter"].must_equal([{"username" => "abc", "url" => "http://twitter.com/abc"}])
    end

    it "allows easy setting of custom data" do
      user = Intercom::User.new()
      user.custom_data["mad"]["stuff"] = [1,2,3]
      user.custom_data["mad"]["stuff"].must_equal [1,2,3]
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
      @mock_rest_client = Intercom.mock_rest_client = mock()
    end

    describe "/v1/users" do
      describe "get" do
        it "fetches a user" do
          @mock_rest_client.expects(:get).with("users", {"email" => "bo@example.com"}).returns(test_user)
          user = Intercom::User.find("email" => "bo@example.com")
          user.email.must_equal "bo@example.com"
          user.name.must_equal "Joe Schmoe"
          user.session_count.must_equal 123
        end
      end

      describe "post" do
        it "saves a user" do
          user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242")
          @mock_rest_client.expects(:post).with("users", {}, {:content_type => :json}, {"email" => "jo@example.com", "user_id" => "i-1224242"}.to_json)
          user.save
        end

        it "can use User.create for convenience" do
          @mock_rest_client.expects(:post).with("users", {}, {:content_type => :json}, {"email" => "jo@example.com", "user_id" => "i-1224242"}.to_json)
          user = Intercom::User.create("email" => "jo@example.com", :user_id => "i-1224242")
          user.email.must_equal "jo@example.com"
        end
      end
    end
  end

  describe "correct use of ssl" do
  end
end