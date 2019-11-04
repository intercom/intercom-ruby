require 'cgi'
require 'net/https'

module Intercom
  class Request
    class << self
      def get(path, params)
        new(path, Net::HTTP::Get.new(append_query_string_to_url(path, params), default_headers))
      end

      def post(path, form_data)
        new(path, method_with_body(Net::HTTP::Post, path, form_data))
      end

      def delete(path, params)
        new(path, method_with_body(Net::HTTP::Delete, path, params))
      end

      def put(path, form_data)
        new(path, method_with_body(Net::HTTP::Put, path, form_data))
      end

      private def method_with_body(http_method, path, params)
        request = http_method.send(:new, path, default_headers)
        request.body = params.to_json
        request["Content-Type"] = "application/json"
        request
      end

      private def default_headers
        {'Accept-Encoding' => 'gzip, deflate', 'Accept' => 'application/vnd.intercom.3+json', 'User-Agent' => "Intercom-Ruby/#{Intercom::VERSION}"}
      end

      private def append_query_string_to_url(url, params)
        return url if params.empty?
        query_string = params.map { |k, v| "#{k.to_s}=#{CGI::escape(v.to_s)}" }.join('&')
        url + "?#{query_string}"
      end
    end

    def initialize(path, net_http_method)
      self.path = path
      self.net_http_method = net_http_method
      self.handle_rate_limit = false
    end

    attr_accessor :handle_rate_limit

    def execute(target_base_url=nil, username:, secret: nil, read_timeout: 90, open_timeout: 30, api_version: nil)
      retries = 3
      base_uri = URI.parse(target_base_url)
      set_common_headers(net_http_method, base_uri)
      set_basic_auth(net_http_method, username, secret)
      set_api_version(net_http_method, api_version) if api_version
      begin
        client(base_uri, read_timeout: read_timeout, open_timeout: open_timeout).start do |http|
          begin
            response = http.request(net_http_method)

            set_rate_limit_details(response)
            raise_errors_on_failure(response)

            parsed_body = extract_response_body(response)

            return nil if parsed_body.nil?

            raise_application_errors_on_failure(parsed_body, response.code.to_i) if parsed_body['type'] == 'error.list'

            parsed_body
          rescue Intercom::RateLimitExceeded => e
            if @handle_rate_limit
              seconds_to_retry = (@rate_limit_details[:reset_at] - Time.now.utc).ceil
              if (retries -= 1) < 0
                raise Intercom::RateLimitExceeded.new('Rate limit retries exceeded. Please examine current API Usage.')
              else
                sleep seconds_to_retry unless seconds_to_retry < 0
                retry
              end
            else
              raise e
            end
          rescue Timeout::Error
            raise Intercom::ServiceUnavailableError.new('Service Unavailable [request timed out]')
          end
        end
      rescue Timeout::Error
        raise Intercom::ServiceConnectionError.new('Failed to connect to service [connection attempt timed out]')
      end
    end

    attr_accessor :path,
                  :net_http_method,
                  :rate_limit_details

    private :path,
            :net_http_method,
            :rate_limit_details

    private def client(uri, read_timeout:, open_timeout:)
      net = Net::HTTP.new(uri.host, uri.port)
      if uri.is_a?(URI::HTTPS)
        net.use_ssl = true
        net.verify_mode = OpenSSL::SSL::VERIFY_PEER
        net.ca_file = File.join(File.dirname(__FILE__), '../data/cacert.pem')
      end
      net.read_timeout = read_timeout
      net.open_timeout = open_timeout
      net
    end

    private def extract_response_body(response)
      decoded_body = decode(response['content-encoding'], response.body)

      json_parse_response(decoded_body, response.code)
    end

    private def decode(content_encoding, body)
      return body if (!body) || body.empty? || content_encoding != 'gzip'
      Zlib::GzipReader.new(StringIO.new(body)).read.force_encoding("utf-8")
    end

    private def json_parse_response(str, code)
      return nil if str.to_s.empty?

      JSON.parse(str)
    rescue JSON::ParserError
      msg = <<~MSG.gsub(/[[:space:]]+/, " ").strip # #squish from ActiveSuppor
        Expected a JSON response body. Instead got '#{str}'
        with status code '#{code}'.
      MSG

      raise UnexpectedResponseError, msg
    end

    private def set_rate_limit_details(response)
      rate_limit_details = {}
      rate_limit_details[:limit] = response['X-RateLimit-Limit'].to_i if response['X-RateLimit-Limit']
      rate_limit_details[:remaining] = response['X-RateLimit-Remaining'].to_i if response['X-RateLimit-Remaining']
      rate_limit_details[:reset_at] = Time.at(response['X-RateLimit-Reset'].to_i) if response['X-RateLimit-Reset']
      @rate_limit_details = rate_limit_details
    end

    private def set_common_headers(method, base_uri)
      method.add_field('AcceptEncoding', 'gzip, deflate')
    end

    private def set_basic_auth(method, username, secret)
      method.basic_auth(CGI.unescape(username), CGI.unescape(secret))
    end

    private def set_api_version(method, api_version)
      method.add_field('Intercom-Version', api_version)
    end

    private def raise_errors_on_failure(res)
      code = res.code.to_i

      if code == 404
        raise Intercom::ResourceNotFound.new('Resource Not Found')
      elsif code == 401
        raise Intercom::AuthenticationError.new('Unauthorized')
      elsif code == 403
        raise Intercom::AuthenticationError.new('Forbidden')
      elsif code == 429
        raise Intercom::RateLimitExceeded.new('Rate Limit Exceeded')
      elsif code == 500
        raise Intercom::ServerError.new('Server Error')
      elsif code == 502
        raise Intercom::BadGatewayError.new('Bad Gateway Error')
      elsif code == 503
        raise Intercom::ServiceUnavailableError.new('Service Unavailable')
      end
    end

    private def raise_application_errors_on_failure(error_list_details, http_code)
      # Currently, we don't support multiple errors
      error_details = error_list_details['errors'].first
      error_code = error_details['type'] || error_details['code']
      error_field = error_details['field']
      parsed_http_code = (http_code > 0 ? http_code : nil)
      error_context = {
        :http_code => parsed_http_code,
        :application_error_code => error_code,
        :field => error_field,
        :request_id => error_list_details['request_id']
      }
      case error_code
      when 'unauthorized', 'forbidden', 'token_not_found'
        raise Intercom::AuthenticationError.new(error_details['message'], error_context)
      when 'token_suspended'
        raise Intercom::AppSuspendedError.new(error_details['message'], error_context)
      when 'token_revoked'
        raise Intercom::TokenRevokedError.new(error_details['message'], error_context)
      when 'token_unauthorized'
        raise Intercom::TokenUnauthorizedError.new(error_details['message'], error_context)
      when "bad_request", "missing_parameter", 'parameter_invalid', 'parameter_not_found'
        raise Intercom::BadRequestError.new(error_details['message'], error_context)
      when "not_restorable"
        raise Intercom::BlockedUserError.new(error_details['message'], error_context)
      when "not_found", "company_not_found"
        raise Intercom::ResourceNotFound.new(error_details['message'], error_context)
      when "admin_not_found"
        raise Intercom::AdminNotFound.new(error_details['message'], error_context)
      when "rate_limit_exceeded"
        raise Intercom::RateLimitExceeded.new(error_details['message'], error_context)
      when "custom_data_limit_reached"
        raise Intercom::CDALimitReachedError.new(error_details['message'], error_context)
      when "invalid_document"
        raise Intercom::InvalidDocumentError.new(error_details['message'], error_context)
      when 'service_unavailable'
        raise Intercom::ServiceUnavailableError.new(error_details['message'], error_context)
      when 'conflict', 'unique_user_constraint'
        raise Intercom::MultipleMatchingUsersError.new(error_details['message'], error_context)
      when 'resource_conflict'
        raise Intercom::ResourceNotUniqueError.new(error_details['message'], error_context)
      when 'intercom_version_invalid'
        raise Intercom::ApiVersionInvalid.new(error_details['message'], error_context)
      when 'scroll_exists'
        raise Intercom::ScrollAlreadyExistsError.new(error_details['message'], error_context)
      when nil, ''
        raise Intercom::UnexpectedError.new(message_for_unexpected_error_without_type(error_details, parsed_http_code), error_context)
      else
        raise Intercom::UnexpectedError.new(message_for_unexpected_error_with_type(error_details, parsed_http_code), error_context)
      end
    end

    private def message_for_unexpected_error_with_type(error_details, parsed_http_code)
      "The error of type '#{error_details['type']}' is not recognized. It occurred with the message: #{error_details['message']} and http_code: '#{parsed_http_code}'. Please contact Intercom with these details."
    end

    private def message_for_unexpected_error_without_type(error_details, parsed_http_code)
      "An unexpected error occured. It occurred with the message: #{error_details['message']} and http_code: '#{parsed_http_code}'. Please contact Intercom with these details."
    end
  end
end
