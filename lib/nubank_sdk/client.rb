# frozen_string_literal: true

require 'faraday'
require 'json'

module NubankSdk
  module Client
    def self.get_body(response)
      JSON.parse(response.body, symbolize_names: true)
    end

    class HTTP
      def initialize(base_url, adapter = nil)
        @connection = Faraday.new(url: base_url) do |faraday|
          faraday.adapter *adapter if adapter
          faraday.adapter Faraday.default_adapter unless adapter
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
      def initialize(certificate, adapter = nil)
        client_cert = OpenSSL::X509::Certificate.new(certificate.certificate),
        client_key = OpenSSL::PKey::RSA.new(certificate.key)

        @connection = Faraday.new(ssl: { client_cert: client_cert, client_key: client_key}) do |faraday|
          faraday.adapter *adapter if adapter
          faraday.adapter Faraday.default_adapter unless adapter
        end
      end

      def post(url, body)
        @connection.post(url) do |req|
          req.headers['Content-Type'] = 'application/json'
          req.body = body.to_json
        end
      end
    end
  end
end
