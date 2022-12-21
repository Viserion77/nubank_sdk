# frozen_string_literal: true

require 'faraday'
require 'json'

module NubankSdk
  module Client
    #
    # Parse the response body symbolizing keys
    #
    # @param [Faraday::Response] response
    #
    # @return [Hash]
    def self.get_body(response)
      JSON.parse(response.body, symbolize_names: true)
    end

    class HTTP
      #
      # create a new connection with the given url in Faraday
      #
      # @param [String] base_url
      # @param [[Symbol, Faraday::Adapter::Test::Stubs]] connection_adapter
      def initialize(base_url, connection_adapter = nil)
        @connection = Faraday.new(url: base_url) do |faraday|
          faraday.adapter(*connection_adapter) if connection_adapter
          faraday.adapter Faraday.default_adapter unless connection_adapter
        end
      end

      #
      # make put on connection with the given path
      #
      # @param [String] path
      # @param [Hash] body
      #
      # @return [Faraday::Response]
      def post(path, body)
        @connection.post(path) do |req|
          req.headers['Content-Type'] = 'application/json'
          req.body = body.to_json
        end
      end

      #
      # make get on connection with the given path
      #
      # @param [String] path
      #
      # @return [Faraday::Response]
      def get(path)
        @connection.get(path)
      end
    end

    class HTTPS
      attr_accessor :headers

      #
      # Create a new instance of Faraday::Connection with client certificate
      #
      # @param [OpenSSL::PKCS12] certificate
      # @param [[Symbol, Faraday::Adapter::Test::Stubs]] connection_adapter
      def initialize(certificate, connection_adapter = nil)
        client_cert = OpenSSL::X509::Certificate.new(certificate.certificate)
        client_key = OpenSSL::PKey::RSA.new(certificate.key)

        @connection = Faraday.new(
          ssl: {
            client_cert: client_cert,
            client_key: client_key
          }
        ) { |faraday| faraday.adapter(*connection_adapter) if connection_adapter }
        @headers = {}
      end

      #
      # Make a post request on connection
      #
      # @param [String] url
      # @param [Hash] body
      #
      # @return [Faraday::Response]
      def post(url, body)
        @connection.post(url) do |req|
          req.headers['Content-Type'] = 'application/json'
          req.headers['X-Correlation-Id'] = '772428d8-f0ee-43d6-8093-a13de3c9ce96'
          req.headers['User-Agent'] = "NubankSdk Client (#{NubankSdk::VERSION})"

          @headers.each do |header_key, value|
            req.headers[header_key] = value
          end

          req.body = body.to_json
        end
      end

      #
      # Make a get request on connection
      #
      # @param [String] url
      #
      # @return [Faraday::Response]
      def get(url)
        @connection.get(url) do |req|
          req.headers['X-Correlation-Id'] = '772428d8-f0ee-43d6-8093-a13de3c9ce96'
          req.headers['User-Agent'] = "NubankSdk Client (#{NubankSdk::VERSION})"

          @headers.each do |header_key, value|
            req.headers[header_key] = value
          end
        end
      end
    end
  end
end
