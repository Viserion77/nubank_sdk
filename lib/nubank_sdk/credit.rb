# frozen_string_literal: true

module NubankSdk
  #
  # Returns the credit statement
  #
  class Credit
    #
    # Returns the credit statement
    #
    # @param [NubankSdk::Client::HTTPS] connection
    # @param [NubankSdk::ApiRoutes] api_routes
    def initialize(connection:, api_routes:)
      @connection = connection
      @api_routes = api_routes
    end

    #
    # Returns the credit balances
    #
    # @return [Hash<Symbol, Float>] the credit balances
    def balances
      account_url = @api_routes.entrypoint(path: :ssl, entrypoint: :account)

      response = @connection.get(account_url)
      response_hash = Client.get_body(response)

      response_hash[:account][:balances]
    end

    #
    # Returns the credit feed
    #
    # @return [Array<Hash>] the credit feed
    def feed
      feed_url = @api_routes.entrypoint(path: :ssl, entrypoint: :feed)

      response = @connection.get(feed_url)

      data = Client.get_body(response)
      data[:events]
    end

    #
    # Returns the cards summary
    #
    # @return [Array<Hash>] the cards summary
    def cards
      # cards_url vem do 'https://prod-s7-facade.nubank.com.br/api/customers/${id}/dashboard'
      # porem isso retorna muito dado... então vamos chumbar :D
      customer_id = @api_routes.entrypoint(path: :ssl, entrypoint: :customer).split('/').last
      cards_url = "https://prod-s7-mr-white.nubank.com.br/api/customers/#{customer_id}/card-summaries"

      puts cards_url
      response = @connection.get(cards_url)

      data = Client.get_body(response)
      data[:sections].map { |section| section[:cards] }.flatten
    end
  end
end
