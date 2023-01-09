# frozen_string_literal: true

require 'graphql/account'

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
          'query': Graphql::Account::BALANCE
        }
      )

      data = Client.get_body(response)
      data[:data][:viewer][:savingsAccount][:currentSavingsBalance][:netAmount]
    end

    #
    # Returns the account feed
    #
    # @return [Array<Hash>]
    def feed
      query_url = @api_routes.entrypoint(path: :ssl, entrypoint: :query)

      response = @connection.post(
        query_url, {
          'variables': {},
          'query': Graphql::Account::FEED
        }
      )

      data = Client.get_body(response)
      data[:data][:viewer][:savingsAccount][:feed]
    end
  end
end
