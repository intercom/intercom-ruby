# frozen_string_literal: true

module Intercom
  class MisconfiguredClientError < StandardError; end
  class Client
    include Options
    include DeprecatedResources
    attr_reader :base_url, :rate_limit_details, :token, :handle_rate_limit, :timeouts, :api_version

    class << self
      def set_base_url(base_url)
        proc do |o|
          old_url = o.base_url
          o.send(:base_url=, base_url)
          proc { |_obj| set_base_url(old_url).call(o) }
        end
      end

      def set_timeouts(open_timeout: nil, read_timeout: nil)
        proc do |o|
          old_timeouts = o.timeouts
          timeouts = {}
          timeouts[:open_timeout] = open_timeout if open_timeout
          timeouts[:read_timeout] = read_timeout if read_timeout
          o.send(:timeouts=, timeouts)
          proc { |_obj| set_timeouts(old_timeouts).call(o) }
        end
      end
    end

    def initialize(token: nil, base_url: 'https://api.intercom.io', handle_rate_limit: false, api_version: nil)
      @token = token
      validate_credentials!

      @api_version = api_version
      validate_api_version!

      @base_url = base_url
      @rate_limit_details = {}
      @handle_rate_limit = handle_rate_limit
      @timeouts = {
        open_timeout: 30,
        read_timeout: 90
      }
    end

    def admins
      Intercom::Service::Admin.new(self)
    end

    def articles
      Intercom::Service::Article.new(self)
    end

    def companies
      Intercom::Service::Company.new(self)
    end

    def contacts
      Intercom::Service::Contact.new(self)
    end

    def conversations
      Intercom::Service::Conversation.new(self)
    end

    def counts
      Intercom::Service::Counts.new(self)
    end

    def events
      Intercom::Service::Event.new(self)
    end

    def messages
      Intercom::Service::Message.new(self)
    end

    def notes
      Intercom::Service::Note.new(self)
    end

    def subscriptions
      Intercom::Service::Subscription.new(self)
    end

    def segments
      Intercom::Service::Segment.new(self)
    end

    def sections
      Intercom::Service::Section.new(self)
    end

    def tags
      Intercom::Service::Tag.new(self)
    end

    def teams
      Intercom::Service::Team.new(self)
    end

    def users
      Intercom::Service::User.new(self)
    end

    def leads
      Intercom::Service::Lead.new(self)
    end

    def visitors
      Intercom::Service::Visitor.new(self)
    end

    def jobs
      Intercom::Service::Job.new(self)
    end

    def data_attributes
      Intercom::Service::DataAttribute.new(self)
    end

    def collections
      Intercom::Service::Collection.new(self)
    end

    def export_content
      Intercom::Service::ExportContent.new(self)
    end

    def phone_call_redirect
      Intercom::Service::PhoneCallRedirect.new(self)
    end

    def get(path, params)
      execute_request Intercom::Request.get(path, params)
    end

    def post(path, payload_hash)
      execute_request Intercom::Request.post(path, payload_hash)
    end

    def put(path, payload_hash)
      execute_request Intercom::Request.put(path, payload_hash)
    end

    def delete(path, payload_hash)
      execute_request Intercom::Request.delete(path, payload_hash)
    end

    private

    def validate_credentials!
      error = MisconfiguredClientError.new('an access token must be provided')
      raise error if @token.nil?
    end

    def validate_api_version!
      error = MisconfiguredClientError.new('api_version must be either nil or a valid API version')
      raise error if @api_version && @api_version != 'Unstable' && Gem::Version.new(@api_version) < Gem::Version.new('1.0')
    end

    def execute_request(request)
      request.handle_rate_limit = handle_rate_limit
      request.execute(@base_url, token: @token, api_version: @api_version, **timeouts)
    ensure
      @rate_limit_details = request.rate_limit_details
    end

    attr_writer :base_url

    def timeouts=(timeouts)
      @timeouts = @timeouts.merge(timeouts)
    end
  end
end
