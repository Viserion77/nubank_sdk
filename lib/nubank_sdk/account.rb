# frozen_string_literal: true

module NubankSdk
  #
  # Returns the account statement
  #
  class Account
    #
    # Returns the account statement
    #
    # @param [NubankSdk::Client::HTTPS] connection
    # @param [NubankSdk::ApiRoutes] api_routes
    def initialize(connection:, api_routes:)
      @connection = connection
      @api_routes = api_routes
    end

    #
    # Returns the account balance
    #
    # @return [Float]
    def balance
      query_url = @api_routes.entrypoint(path: :ssl, entrypoint: :query)

      response = @connection.post(
        query_url, {
          'variables': {},
          'query': '{viewer {savingsAccount {currentSavingsBalance {netAmount}}}}'
        }
      )

      data = NubankSdk::Client.get_body(response)
      data[:data][:viewer][:savingsAccount][:currentSavingsBalance][:netAmount]
    end

    #
    # Returns the account feed
    #
    def feed
      query_url = @api_routes.entrypoint(path: :ssl, entrypoint: :query)

      response = @connection.post(
        query_url, {
          'variables': {},
          'query': NubankSdk::Utils.read_graphql_query('account', 'feed')
        }
      )

      data = NubankSdk::Client.get_body(response)
      data[:data][:viewer][:savingsAccount][:feed]
    end
  end
end
