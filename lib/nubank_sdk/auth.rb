module NubankSdk
  class Auth
    attr_reader :refresh_token, :refresh_before, :access_token

    #
    # Auth method to connect with the nubank api
    #
    # @param [String] cpf the cpf to authenticate
    # @param [String] device_id the device id to authenticate
    # @param [NubankSdk::ApiRoutes] api_routes the api routes to connect
    # @param [[Symbol, Faraday::Adapter::Test::Stubs]] adapter the adapter to connect
    def initialize(cpf:, device_id: nil, api_routes: nil, connection_adapter: nil)
      @cpf = cpf
      @device_id = device_id || generate_device_id
      @api_routes = api_routes || NubankSdk::ApiRoutes.new

      @connection_adapter = connection_adapter
    end

    #
    # Return the instance of user certificate
    #
    # @return [NubankSdk::Certificate] the certificate instance
    def certificate
      @certificate ||= NubankSdk::Certificate.new(@cpf)
    end

    #
    # Authenticate with the nubank api to get a new access token
    #
    # @param [String] password the password to authenticate
    #
    # @return [NubankSdk::ApiRoutes] the api routes with the new links
    def authenticate_with_certificate(password)
      token_url = @api_routes.entrypoint(path: :app, entrypoint: :token)
      response = ssl_connection.post(token_url, token_payload(password))

      response_hash = Client.get_body(response)

      @refresh_token = response_hash[:refresh_token]
      @refresh_before = response_hash[:refresh_before]
      @access_token = response_hash[:access_token]

      update_api_routes(response_hash[:_links])
    end

    #
    # Request to nubank api to generate a new certificate
    #
    # @param [String] password the password to authenticate
    #
    # @return [String] email was has been received the code
    def request_email_code(password)
      response = default_connection.post(@gen_certificate_path, payload(password))

      response_parsed = parse_authenticate_headers(response.headers['WWW-Authenticate'])
      @encrypted_code = response_parsed[:device_authorization_encrypted_code]

      response_parsed[:sent_to]
    end

    #
    # Verify communication with the nubank api
    #
    # @return [File] the certificate file
    def exchange_certs(email_code, password)
      response = default_connection.post(@gen_certificate_path, payload(password).merge({
          code: email_code,
          'encrypted-code': @encrypted_code
        })
      )

      response_data = Client.get_body(response)
      certificate.process_decoded(key, response_data[:certificate])
    end

    private

    # @!visibility private
    # parse the headers of the authenticate response
    #
    # @param [String] header_content the headers to parse
    #
    # @return [Hash] the parsed header
    def parse_authenticate_headers(header_content)
      chunks = header_content.split(',')
      parsed = {}

      chunks.each do |chunk|
          key, value = chunk.split('=')
          key = key.strip().gsub(' ', '_').gsub('-', '_').to_sym
          value = value.gsub('"', '')
          parsed[key] = value
      end
    
      parsed
    end

    # @!visibility private
    # Create a payload to generate a new certificate
    #
    # @param [String] password the password to authenticate
    #
    # @return [Hash] the payload to generate a new certificate
    def payload(password)
      {
        login: @cpf,
        password: password,
        public_key: key.public_key.to_pem,
        device_id: @device_id,
        model: "NubankSdk Client (#@device_id)",
      }
    end

    # @!visibility private
    # Create a payload to authenticate with the nubank api
    #
    # @param [String] password the password to authenticate
    #
    # @return [Hash] the payload to authenticate
    def token_payload(password)
      {
        'grant_type': 'password',
        'client_id': 'legacy_client_id',
        'client_secret': 'legacy_client_secret',
        'login': @cpf,
        'password': password
      }
    end

    # @!visibility private
    # Generates a new key for the certificate communication
    #
    # @return [OpenSSL::PKey::RSA] a new key
    def generate_key
      OpenSSL::PKey::RSA.new 2048
    end

    # @!visibility private
    # Add the new links to the api routes
    #
    # @param [Hash] links the new links to add
    #
    # @return [NubankSdk::ApiRoutes] the api routes with the new links
    def update_api_routes(links)
      feed_url_keys = ['events', 'magnitude']
      bills_url_keys = ['bills_summary']
      customer_url_keys = ['customer']
      account_url_keys = ['account']
      @api_routes.add_entrypoint(path: :ssl, entrypoint: :revoke_token, url: links[:revoke_token][:href])
      @api_routes.add_entrypoint(path: :ssl, entrypoint: :query, url: links[:ghostflame][:href])
      @api_routes.add_entrypoint(path: :ssl, entrypoint: :feed, url: find_url(feed_url_keys, links))
      @api_routes.add_entrypoint(path: :ssl, entrypoint: :bills, url: find_url(bills_url_keys, links))
      @api_routes.add_entrypoint(path: :ssl, entrypoint: :customer, url: find_url(customer_url_keys, links))
      @api_routes.add_entrypoint(path: :ssl, entrypoint: :account, url: find_url(account_url_keys, links))
      @api_routes
    end

    # @!visibility private
    # Return the url of the first key found in the links
    #
    # @param [Array] keys the keys to search in the links
    # @param [Hash] list of the links to search in
    #
    # @return [String] the url of the first key found
    def find_url(keys, list)
      links_keys = list.keys

      keys.each do |url_key|
        return list[url_key]['href'] if links_keys.include?(url_key)
      end
      ''
    end

    # @!visibility private
    # Generates a new connection with certificate
    #
    # @return [Client::HTTPS] a new connection with certificate
    def prepare_default_connection
      uri, @gen_certificate_path = @api_routes.entrypoint(
        path: :app,
        entrypoint: :gen_certificate,
        type: :splitted
      )

      Client::HTTP.new(uri, @connection_adapter)
    end

    # @!visibility private
    # Create a new default connection to the nubank api
    #
    # @return [Client::HTTP] a new default connection
    def default_connection
      @default_connection ||= prepare_default_connection
    end

    # @!visibility private
    # Create a new ssl connection to the nubank api
    #
    # @return [Client::HTTPS] a new ssl connection
    def ssl_connection
      @ssl_connection ||= Client::HTTPS.new(certificate.encoded, @connection_adapter)
    end

    # @!visibility private
    # return the key of the certificate communication
    #
    # @return [OpenSSL::PKey::RSA] the key of the certificate
    def key
      @key ||= generate_key
    end

    # @!visibility private
    # Generates a random device id
    #
    # @return [String] a random device id
    def generate_device_id
      SecureRandom.uuid.split('-').last
    end
  end
end
