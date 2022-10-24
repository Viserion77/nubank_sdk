module NubankSdk
  class Account
    attr_reader :cpf, :device_id

    def initialize(cpf:, key:, device_id: nil, adapter: nil)
      @cpf = cpf
      @device_id = device_id || generate_device_id

      @api_routes = NubankSdk::ApiRoutes.new(connection_adapter: adapter)
      @adapter = adapter
      @key = key
    end

    def auth
      @auth ||= NubankSdk::Auth.new(
        cpf: @cpf,
        key: @key,
        device_id: @device_id,
        api_routes: @api_routes,
        adapter: @adapter
      )
    end

    def account_balance
      query_url = auth.api_routes.entrypoint(path: :ssl, entrypoint: :query)
      connection = Client::HTTPS.new(auth.certificate.encoded, @adapter)

      response = connection.post(query_url, {
        'variables': {},
        'query': '{viewer {savingsAccount {currentSavingsBalance {netAmount}}}}'
      }, { Authorization: "Bearer #{auth.access_token}" })

      data = JSON.parse(response.body, symbolize_names: true)
      data[:data][:viewer][:savingsAccount][:currentSavingsBalance][:netAmount]
    end

    private

    def generate_device_id
      SecureRandom.uuid.split('-').last
    end
  end
end