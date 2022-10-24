# frozen_string_literal: true

module NubankSdk
  class Auth
    attr_reader :refresh_token, :refresh_before, :access_token

    def initialize(cpf:, device_id:, key: nil, api_routes: nil, adapter: nil)
      @cpf = cpf
      @device_id = device_id
      @key = key || generate_key
      @api_routes = api_routes || NubankSdk::ApiRoutes.new

      @adapter = adapter
    end

    def api_routes
      @api_routes
    end

    def certificate
      @certificate ||= NubankSdk::Certificate.new(@cpf, @key)
    end

    def authenticate_with_certificate(password)
      token_url = @api_routes.entrypoint(path: :app, entrypoint: :token)
      response = ssl_connection.post(token_url, token_payload(password))

      response_hash = Client.get_body(response)

      @refresh_token = response_hash[:refresh_token]
      @refresh_before = response_hash[:refresh_before]
      @access_token = response_hash[:access_token]

      update_api_routes(response_hash[:_links])
    end

    def request_email_code(password)
      response = default_connection.post(@gen_certificate_path, payload(password))

      response_parsed = parse_authenticate_headers(response.headers['WWW-Authenticate'])
      @encrypted_code = response_parsed[:device_authorization_encrypted_code]

      response_parsed[:sent_to]
    end

    def exchange_certs(email_code, password)
      response = default_connection.post(@gen_certificate_path, payload(password).merge({
          code: email_code,
          'encrypted-code': @encrypted_code
        })
      )

      response_data = Client.get_body(response)
      certificate.process_decoded response_data[:certificate]
    end

    private

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

    def payload(password)
      {
        login: @cpf,
        password: password,
        public_key: @key.public_key.to_pem,
        device_id: @device_id,
        model: "NubankSdk Client (#@device_id)",
      }
    end

    def token_payload(password)
      {
        'grant_type': 'password',
        'client_id': 'legacy_client_id',
        'client_secret': 'legacy_client_secret',
        'login': @cpf,
        'password': password
      }
    end

    def generate_key
      OpenSSL::PKey::RSA.new 2048
    end

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
    end

    def find_url(keys, list)
      links_keys = list.keys

      keys.each do |key|
        return list[key]['href'] if links_keys.include?(key)
      end
      ''
    end

    def prepare_connections
      uri, @gen_certificate_path = @api_routes.entrypoint(
        path: :app,
        entrypoint: :gen_certificate,
        type: :splitted
      )

      Client::HTTP.new(uri, @adapter)
    end

    def default_connection
      @default_connection ||= prepare_connections
    end

    def ssl_connection
      @ssl_connection ||= Client::HTTPS.new(certificate.encoded, @adapter)
    end
  end
end
