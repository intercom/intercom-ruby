require "spec_helper"

describe Intercom do
  before do
    Intercom.app_id = "abc123"
    Intercom.secret_key = "super-secret-key"
    @mock_rest_client = Intercom.mock_rest_client = mock()
  end

  it "has a version number" do
    Intercom::VERSION.must_equal "0.0.1"
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
        user = Intercom::User.new("email" => "jo@example.com", "user_id" => "i-1224242")
        @mock_rest_client.expects(:post).with("users", {}, {:content_type => :json}, {"email" => "bo@example.com"}.to_json)
        user.save
      end
    end
  end

  describe "correct use of ssl" do
  end
end