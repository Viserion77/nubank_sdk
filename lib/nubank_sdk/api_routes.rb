require 'faraday'
require 'json'

module NubankSdk
  class ApiRoutes
    DISCOVERY_URI = 'https://prod-s0-webapp-proxy.nubank.com.br'.freeze
    PROXY_PATHS = {
      default: '/api/discovery',
      app: '/api/app/discovery',
      ssl: ''
    }.freeze

    def initialize(url_discovery_map: {}, connection_adapter: nil)
      @url_discovery_map = url_discovery_map
      @connection_adapter = connection_adapter
    end

    # types: :splitted, :full
    def entrypoint(path: :default, entrypoint:, type: :full)
      discovery(path) if @url_discovery_map[path].nil?

      url = @url_discovery_map[path][entrypoint]

      return url if type == :full

      url_splitted = url.split('/api')
      [url_splitted.first, "/api#{url_splitted.last}"]
    end

    def add_entrypoint(path: :default, entrypoint:, url:)
      path_map = @url_discovery_map[path] || {}
      path_map[entrypoint] = url

      @url_discovery_map[path] = path_map
    end

    private

    def discovery(path = :default)
      return @url_discovery_map[path] if @url_discovery_map[path]

      response = connection.get(PROXY_PATHS[path])
      url_map = Client.get_body(response)

      @url_discovery_map[path] = url_map
    end

    def connection
      @connection ||= Client::HTTP.new(DISCOVERY_URI, @connection_adapter)
    end
  end
end
