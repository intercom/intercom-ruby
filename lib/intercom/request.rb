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
      method.add_field('Accept', 'application/json')
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
      {'Accept-Encoding' => 'gzip, deflate', 'Accept' => 'application/json'}
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
      client(base_uri).start do |http|
        response = http.request(net_http_method)
        raise_errors_on_failure(response)
        decoded = decode(response['content-encoding'], response.body)
        JSON.parse(decoded) unless decoded.empty?
      end
    rescue Timeout::Error
      raise Intercom::ServiceUnavailableError
    end

    def decode(content_encoding, body)
      return body if (!body) || body.empty? || content_encoding != 'gzip'
      Zlib::GzipReader.new(StringIO.new(body)).read
    end

    def raise_errors_on_failure(res)
      if res.code.to_i.eql?(404)
        raise Intercom::ResourceNotFound
      elsif res.code.to_i.eql?(401)
        raise Intercom::AuthenticationError
      elsif res.code.to_i.eql?(500)
        raise Intercom::ServerError
      elsif res.code.to_i.eql?(502)
        raise Intercom::BadGatewayError
      elsif res.code.to_i.eql?(503)
        raise Intercom::ServiceUnavailableError
      end
    end

    def self.append_query_string_to_url(url, params)
      return url if params.empty?
      query_string = params.map { |k, v| "#{k.to_s}=#{CGI::escape(v.to_s)}" }.join('&')
      url + "?#{query_string}"
    end
  end
end
