# frozen_string_literal: true

require 'faraday'
require 'json'

module NubankSdk
  module Client
    def self.get_body(response)
      JSON.parse(response.body, symbolize_names: true)
    end

    class HTTP
      def initialize(base_url, connection_adapter = nil)
        @connection = Faraday.new(url: base_url) do |faraday|
          faraday.adapter *connection_adapter if connection_adapter
          faraday.adapter Faraday.default_adapter unless connection_adapter
        end
      end

      def post(path, body)
        @connection.post(path) do |req|
          req.headers['Content-Type'] = 'application/json'
          req.body = body.to_json
        end
      end

      def get(path)
        @connection.get(path)
      end
    end

    class HTTPS
      attr_accessor :headers

      def initialize(certificate, connection_adapter = nil)
        client_cert = OpenSSL::X509::Certificate.new(certificate.certificate)
        client_key = OpenSSL::PKey::RSA.new(certificate.key)

        @connection = Faraday.new(ssl: { client_cert: client_cert, client_key: client_key}) do |faraday|
          faraday.adapter *connection_adapter if connection_adapter
          faraday.adapter Faraday.default_adapter unless connection_adapter
        end
      end

      def post(url, body)
        @connection.post(url) do |req|
          req.headers['Content-Type'] = 'application/json'
          req.headers['X-Correlation-Id'] = '772428d8-f0ee-43d6-8093-a13de3c9ce96'
          req.headers['User-Agent'] = "NubankSdk Client (#{NubankSdk::VERSION})"

          @headers.each do |header_key, value|
            req.headers[header_key] = value
          end unless @headers.nil?

          req.body = body.to_json
        end
      end
    end
  end
end
