require 'cgi'
require 'net/https'

module Intercom
  class Request
    attr_accessor :path, :net_http_method

    def initialize(path, net_http_method)
      self.path = path
      self.net_http_method = net_http_method
    end

    def set_common_headers(method, base_uri)
      method.basic_auth(CGI.unescape(base_uri.user), CGI.unescape(base_uri.password))
      method.add_field('AcceptEncoding', 'gzip, deflate')
    end

    def self.get(path, params)
      new(path, Net::HTTP::Get.new(append_query_string_to_url(path, params), default_headers))
    end

    def self.post(path, form_data)
      new(path, method_with_body(Net::HTTP::Post, path, form_data))
    end

    def self.delete(path, params)
      new(path, method_with_body(Net::HTTP::Delete, path, params))
    end

    def self.put(path, form_data)
      new(path, method_with_body(Net::HTTP::Put, path, form_data))
    end

    def self.method_with_body(http_method, path, params)
      request = http_method.send(:new, path, default_headers)
      request.body = params.to_json
      request["Content-Type"] = "application/json"
      request
    end

    def self.default_headers
      {'Accept-Encoding' => 'gzip, deflate', 'Accept' => 'application/vnd.intercom.3+json', 'User-Agent' => "Intercom-Ruby/#{Intercom::VERSION}"}
    end

    def client(uri)
      net = Net::HTTP.new(uri.host, uri.port)
      if uri.is_a?(URI::HTTPS)
        net.use_ssl = true
        net.verify_mode = OpenSSL::SSL::VERIFY_PEER
        net.ca_file = File.join(File.dirname(__FILE__), '../data/cacert.pem')
      end
      net.read_timeout = 90
      net.open_timeout = 30
      net
    end

    def execute(target_base_url=nil)
      base_uri = URI.parse(target_base_url)
      set_common_headers(net_http_method, base_uri)
      begin
        client(base_uri).start do |http|
          begin
            response = http.request(net_http_method)
            decoded = decode(response['content-encoding'], response.body)
            unless decoded.strip.empty?
              parsed_body = JSON.parse(decoded)
              raise_application_errors_on_failure(parsed_body, response.code.to_i) if parsed_body['type'] == 'error.list'
            end
            raise_errors_on_failure(response)
            parsed_body
          rescue Timeout::Error
            raise Intercom::ServiceUnavailableError.new('Service Unavailable [request timed out]')
          end
        end
      rescue Timeout::Error
        raise Intercom::ServiceConnectionError.new('Failed to connect to service [connection attempt timed out]')
      end
    end

    def decode(content_encoding, body)
      return body if (!body) || body.empty? || content_encoding != 'gzip'
      Zlib::GzipReader.new(StringIO.new(body)).read
    end

    def raise_errors_on_failure(res)
      if res.code.to_i.eql?(404)
        raise Intercom::ResourceNotFound.new('Resource Not Found')
      elsif res.code.to_i.eql?(401)
        raise Intercom::AuthenticationError.new('Unauthorized')
      elsif res.code.to_i.eql?(403)
        raise Intercom::AuthenticationError.new('Forbidden')
      elsif res.code.to_i.eql?(500)
        raise Intercom::ServerError.new('Server Error')
      elsif res.code.to_i.eql?(502)
        raise Intercom::BadGatewayError.new('Bad Gateway Error')
      elsif res.code.to_i.eql?(503)
        raise Intercom::ServiceUnavailableError.new('Service Unavailable')
      end
    end

    def raise_application_errors_on_failure(error_list_details, http_code)
      # Currently, we don't support multiple errors
      error_details = error_list_details['errors'].first
      error_code = error_details['type'] || error_details['code']
      parsed_http_code = (http_code > 0 ? http_code : nil)
      error_context = {
        :http_code => parsed_http_code,
        :application_error_code => error_code
      }
      case error_code
      when 'unauthorized', 'forbidden'
        raise Intercom::AuthenticationError.new(error_details['message'], error_context)
      when "bad_request", "missing_parameter", 'parameter_invalid'
        raise Intercom::BadRequestError.new(error_details['message'], error_context)
      when "not_found"
        raise Intercom::ResourceNotFound.new(error_details['message'], error_context)
      when "rate_limit_exceeded"
        raise Intercom::RateLimitExceeded.new(error_details['message'], error_context)
      when 'service_unavailable'
        raise Intercom::ServiceUnavailableError.new(error_details['message'], error_context)
      when nil, ''
        raise Intercom::UnexpectedError.new(message_for_unexpected_error_without_type(error_details, parsed_http_code), error_context)
      else
        raise Intercom::UnexpectedError.new(message_for_unexpected_error_with_type(error_details, parsed_http_code), error_context)
      end
    end

    def message_for_unexpected_error_with_type(error_details, parsed_http_code)
      "The error of type '#{error_details['type']}' is not recognized. It occurred with the message: #{error_details['message']} and http_code: '#{parsed_http_code}'. Please contact Intercom with these details."
    end

    def message_for_unexpected_error_without_type(error_details, parsed_http_code)
      "An unexpected error occured. It occurred with the message: #{error_details['message']} and http_code: '#{parsed_http_code}'. Please contact Intercom with these details."
    end

    def self.append_query_string_to_url(url, params)
      return url if params.empty?
      query_string = params.map { |k, v| "#{k.to_s}=#{CGI::escape(v.to_s)}" }.join('&')
      url + "?#{query_string}"
    end
  end
end
