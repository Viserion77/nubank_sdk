# frozen_string_literal: true

module NubankSdk
  class User
    def initialize(cpf:, connection_adapter: nil)
      @cpf = cpf
      @connection_adapter = connection_adapter
    end

    def auth
      @auth ||= NubankSdk::Auth.new(
        cpf: @cpf,
        api_routes: api_routes,
        connection_adapter: @connection_adapter
      )
    end

    def account
      @account ||= NubankSdk::Account.new(connection: connection, api_routes: api_routes)
    end

    def api_routes
      @api_routes ||= NubankSdk::ApiRoutes.new
    end

    private

    def connection
      @connection ||= setup_connection
    end

    def setup_connection
      connection = Client::HTTPS.new(
        auth.certificate.encoded,
        @connection_adapter
      )
      connection.headers = { 'Authorization': "Bearer #{auth.access_token}" }
      connection
    end
  end
end
