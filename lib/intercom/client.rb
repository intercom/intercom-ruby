module Intercom
  class MisconfiguredClientError < StandardError; end
  class Client
    include Options
    attr_reader :base_url, :rate_limit_details, :username_part, :password_part, :handle_rate_limit, :timeouts, :api_version

    class << self
      def set_base_url(base_url)
        return Proc.new do |o|
          old_url = o.base_url
          o.send(:base_url=, base_url)
          Proc.new { |obj| set_base_url(old_url).call(o) }
        end
      end

      def set_timeouts(open_timeout: nil, read_timeout: nil)
        return Proc.new do |o|
          old_timeouts = o.timeouts
          timeouts = {}
          timeouts[:open_timeout] = open_timeout if open_timeout
          timeouts[:read_timeout] = read_timeout if read_timeout
          o.send(:timeouts=, timeouts)
          Proc.new { |obj| set_timeouts(old_timeouts).call(o) }
        end
      end
    end

    def initialize(app_id: 'my_app_id', api_key: 'my_api_key', token: nil, base_url:'https://api.intercom.io', handle_rate_limit: false, api_version: nil)
      if token
        @username_part = token
        @password_part = ""
      else
        @username_part = app_id
        @password_part = api_key
      end
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

    def customers
      Intercom::Service::Customer.new(self)
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

    def tags
      Intercom::Service::Tag.new(self)
    end

    def teams
      Intercom::Service::Team.new(self)
    end

    def users
      Intercom::Service::User.new(self)
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
      error = MisconfiguredClientError.new("app_id and api_key must not be nil")
      fail error if @username_part.nil?
    end

    def validate_api_version!
      return if @api_version == "Unstable"

      error = MisconfiguredClientError.new("api_version must be either nil or a valid API version")
      fail error if (@api_version && Gem::Version.new(@api_version) < Gem::Version.new('1.0'))
    end

    def execute_request(request)
      request.handle_rate_limit = handle_rate_limit
      request.execute(@base_url, username: @username_part, secret: @password_part, api_version: @api_version, **timeouts)
    ensure
      @rate_limit_details = request.rate_limit_details
    end

    def base_url=(new_url)
      @base_url = new_url
    end

    def timeouts=(timeouts)
      @timeouts = @timeouts.merge(timeouts)
    end
  end
end
