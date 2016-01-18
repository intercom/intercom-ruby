module Intercom
  class MisconfiguredClientError < StandardError; end
  class Client
    include Options
    attr_reader :base_url, :rate_limit_details

    class << self
      def set_base_url(base_url)
        return Proc.new do |o|
          old_url = o.base_url
          o.send(:base_url=, base_url)
          Proc.new { |obj| set_base_url(old_url).call(o) }
        end
      end
    end

    def initialize(app_id: 'my_app_id', api_key: 'my_api_key')
      @app_id = app_id
      @api_key = api_key
      validate_credentials!

      @base_url = 'https://api.intercom.io'
      @rate_limit_details = {}
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

    def users
      Intercom::Service::User.new(self)
    end

    def jobs
      Intercom::Service::Job.new(self)
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
      fail error if @app_id.nil?
    end

    def execute_request(request)
      result = request.execute(@base_url, username: @app_id, secret: @api_key)
      @rate_limit_details = request.rate_limit_details
      result
    end

    def base_url=(new_url)
      @base_url = new_url
    end
  end
end
