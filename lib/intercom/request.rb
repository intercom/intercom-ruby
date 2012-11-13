require 'cgi'
require 'net/https'

module Intercom
  class Request
    attr_accessor :uri, :net_http_method

    def initialize(uri, net_http_method)
      set_common_headers(net_http_method, uri)

      self.uri = uri
      self.net_http_method = net_http_method
    end

    def set_common_headers(method, uri)
      method.basic_auth(CGI.unescape(uri.user), CGI.unescape(uri.password))
      method.add_field('Accept', 'application/json')
      method.add_field('AcceptEncoding', 'gzip, deflate')
    end

    def self.get(url, params)
      uri = URI.parse(url)
      new(uri, Net::HTTP::Get.new(append_query_string_to_url(uri.path, params), default_headers))
    end

    def self.post(url, form_data)
      uri = URI.parse(url)
      new(uri, method_with_body(Net::HTTP::Post, uri, form_data))
    end

    def self.delete(url, params)
      uri = URI.parse(url)
      new(uri, Net::HTTP::Delete.new(append_query_string_to_url(uri.path, params), default_headers))
    end

    def self.put(url, form_data)
      uri = URI.parse(url)
      new(uri, method_with_body(Net::HTTP::Put, uri, form_data))
    end

    def self.method_with_body(http_method, uri, params)
      request = http_method.send(:new, uri.request_uri, default_headers)
      request.body = params.to_json
      request["Content-Type"] = "application/json"
      request
    end

    def self.default_headers
      {'Accept-Encoding' => 'gzip, deflate', 'Accept' => 'application/json'}
    end

    def client
      net = Net::HTTP.new(uri.host, uri.port)
      if uri.is_a?(URI::HTTPS)
        net.use_ssl = uri.is_a?(URI::HTTPS)
        net.verify_mode = OpenSSL::SSL::VERIFY_PEER
        net.ca_file = File.join(File.dirname(__FILE__), '../data/cacert.pem')
      end
      net.read_timeout = 30
      net.open_timeout = 10
      net
    end

    def execute
      client.start do |http|
        response = http.request(net_http_method)
        raise_errors_on_failure(response)
        decoded = decode(response['content-encoding'], response.body)
        JSON.parse(decoded)
      end
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
      end
    end

    def self.append_query_string_to_url(url, params)
      return url if params.empty?
      query_string = params.map { |k, v| "#{k.to_s}=#{CGI::escape(v.to_s)}" }.join('&')
      url + "?#{query_string}"
    end
  end
end