# frozen_string_literal: true

module NubankSdk
  class User
    #
    # Controller of user actions in nubank
    #
    # @param [String] cpf
    # @param [[Symbol, Faraday::Adapter::Test::Stubs]] connection_adapter
    def initialize(cpf:, connection_adapter: nil)
      @cpf = cpf
      @connection_adapter = connection_adapter
    end

    #
    # Returns instance of authentications methods
    #
    # @return [NubankSdk::Auth]
    def auth
      @auth ||= NubankSdk::Auth.new(
        cpf: @cpf,
        api_routes: api_routes,
        connection_adapter: @connection_adapter
      )
    end

    #
    # Returns instance of account methods
    #
    # @return [NubankSdk::Account]
    def account
      @account ||= NubankSdk::Account.new(connection: connection, api_routes: api_routes)
    end

    #
    # Returns instance of credit methods
    #
    # @return [NubankSdk::Credit]
    def credit
      @credit ||= NubankSdk::Credit.new(connection: connection, api_routes: api_routes)
    end

    #
    # An instance of apis routes
    #
    # @return [NubankSdk::ApiRoutes]
    def api_routes
      @api_routes ||= NubankSdk::ApiRoutes.new
    end

    private

    # @!visibility private
    # Returns connection with client https certificate and authorized
    #
    # @return [Faraday::Connection]
    def connection
      @connection ||= setup_connection
    end

    # @!visibility private
    # Setup connection with client https certificate and authorized
    #
    # @return [Faraday::Connection]
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
