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
      proc { Intercom.target_base_url }.must_raise ArgumentError, "You must set both Intercom.app_id and Intercom.api_key to use this client. See https://github.com/intercom/intercom-ruby for usage examples."
    end

    it "defaults to https to api.intercom.io" do
      Intercom.target_base_url.must_equal "https://abc123:super-secret-key@api.intercom.io"
    end

    it "raises ResourceNotFound if get a 404" do

    end

    describe "overriding protocol/hostname" do
      before do
        @protocol = Intercom.protocol
        @hostname = Intercom.hostname
        Intercom.endpoints = nil
      end

      after do
        Intercom.protocol = @protocol
        Intercom.hostname = @hostname
      end

      it "allows overriding of the endpoint and protocol" do
        Intercom.protocol = "http"
        Intercom.hostname = "localhost:3000"
        Intercom.target_base_url.must_equal "http://abc123:super-secret-key@localhost:3000"
      end

      it "prefers endpoints" do
        Intercom.endpoint = "https://localhost:7654"
        Intercom.target_base_url.must_equal "https://abc123:super-secret-key@localhost:7654"
        Intercom.endpoints = unshuffleable_array(["http://example.com","https://localhost:7654"])
        Intercom.target_base_url.must_equal "http://abc123:super-secret-key@example.com"
      end

      it "has endpoints" do
        Intercom.endpoints.must_equal ["https://api.intercom.io"]
        Intercom.endpoints = ["http://example.com","https://localhost:7654"]
        Intercom.endpoints.must_equal ["http://example.com","https://localhost:7654"]
      end

      it "should randomize endpoints if last checked endpoint is > 5 minutes ago" do
        Intercom.instance_variable_set(:@current_endpoint, "http://start")
        Intercom.instance_variable_set(:@endpoints, ["http://alternative"])
        Intercom.instance_variable_set(:@endpoint_randomized_at, Time.now - 120)
        Intercom.current_endpoint.must_equal "http://start"
        Intercom.instance_variable_set(:@endpoint_randomized_at, Time.now - 360)
        Intercom.current_endpoint.must_equal "http://alternative"
        Intercom.instance_variable_get(:@endpoint_randomized_at).to_i.must_be_close_to Time.now.to_i
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