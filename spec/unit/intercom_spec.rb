require "spec_helper"

describe Intercom do
  it "has a version number" do
    Intercom::VERSION.must_match(/\d+\.\d+\.\d+/)
  end

  describe "API" do
    before do
      Intercom.app_id = "abc123"
      Intercom.api_key = "super-secret-key"
    end

    it "raises ArgumentError if no app_id or api_key specified" do
      Intercom.app_id = nil
      Intercom.api_key = nil
      proc { Intercom.url_for_path("something") }.must_raise ArgumentError, "You must set both Intercom.app_id and Intercom.api_key to use this client. See https://github.com/intercom/intercom-ruby for usage examples."
    end

    it "defaults to https to api.intercom.io" do
      Intercom.url_for_path("some/resource/path").must_equal "https://abc123:super-secret-key@api.intercom.io/v1/some/resource/path"
    end

    it "raises ResourceNotFound if get a 404" do

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
        Intercom.url_for_path("some/resource/path").must_equal "http://abc123:super-secret-key@localhost:3000/v1/some/resource/path"
      end
    end
  end

  it "checks for email or user id" do
    proc { Intercom.check_required_params("else") }.must_raise ArgumentError, "Expected params Hash, got String"
    proc { Intercom.check_required_params(:something => "else") }.must_raise ArgumentError, "Either email or user_id must be specified"
    Intercom.check_required_params(:email => "bob@example.com", :something => "else")
    Intercom.check_required_params("email" => "bob@example.com", :something => "else")
    Intercom.check_required_params(:user_id => "123")
  end
end