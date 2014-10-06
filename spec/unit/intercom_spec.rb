require "spec_helper"
require 'thread'

describe Intercom do
  it "has a version number" do
    Intercom::VERSION.must_match(/\d+\.\d+\.\d+/)
  end

  describe "Thread Safety" do
    it "should be thread safe" do
      app_id = SecureRandom.uuid
      api_key = SecureRandom.uuid
      protocol = SecureRandom.uuid
      hostname = SecureRandom.uuid
      endpoints = SecureRandom.uuid
      endpoint_randomized_at = SecureRandom.uuid

      Thread.new do
        Intercom.app_id = app_id
        Intercom.app_api_key = api_key
        Intercom.protocol = protocol
        Intercom.hostname = hostname
        Intercom.endpoints = endpoints
        Intercom.endpoint_randomized_at = endpoint_randomized_at

        Thread.new do
          Intercom.app_id = SecureRandom.uuid
          Intercom.app_api_key = SecureRandom.uuid
          Intercom.protocol = SecureRandom.uuid
          Intercom.hostname = SecureRandom.uuid
          Intercom.endpoints = SecureRandom.uuid
          Intercom.endpoint_randomized_at = SecureRandom.uuid
        end.join

        assert_equal Intercom.app_id, app_id
        assert_equal Intercom.app_api_key, api_key
        assert_equal Intercom.hostname, hostname
        assert_equal Intercom.protocol, protocol
        assert_equal Intercom.endpoints, endpoints
        assert_equal Intercom.endpoint_randomized_at, endpoint_randomized_at
      end.join
    end
  end

  describe "API" do
    before do
      Intercom.app_id = "abc123"
      Intercom.app_api_key = "super-secret-key"
    end

    it "raises ArgumentError if no app_id or app_api_key specified" do
      Intercom.app_id = nil
      Intercom.app_api_key = nil
      proc { Intercom.target_base_url }.must_raise ArgumentError, "You must set both Intercom.app_id and Intercom.app_api_key to use this client. See https://github.com/intercom/intercom-ruby for usage examples."
    end

    it "returns the app_id and app_api_key previously set" do
      Intercom.app_id.must_equal "abc123"
      Intercom.app_api_key.must_equal "super-secret-key"
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
        Intercom.endpoints = ["https://api.intercom.io"]
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
        Thread.current[:intercom_current_endpoint] = "http://start"
        Thread.current[:intercom_endpoints] = ["http://alternative"]
        Thread.current[:intercom_endpoint_randomized_at] = Time.now - 120
        Intercom.current_endpoint.must_equal "http://start"
        Thread.current[:intercom_endpoint_randomized_at] = Time.now - 360
        Intercom.current_endpoint.must_equal "http://alternative"
        Thread.current[:intercom_endpoint_randomized_at].to_i.must_be_close_to Time.now.to_i
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
