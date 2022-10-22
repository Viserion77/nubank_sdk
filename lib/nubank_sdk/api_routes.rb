# frozen_string_literal: true

require 'faraday'
require 'json'

module NubankSdk
  class ApiRoutes
    DISCOVERY_URI = "https://prod-s0-webapp-proxy.nubank.com.br"
    PROXY_PATHS = {
      default: '/api/discovery',
      app: '/api/app/discovery',
      ssl: '',
    }

    def initialize(url_discovery_map: {}, connection_adapter: nil)
      @url_discovery_map = url_discovery_map
      @connection_adapter = connection_adapter
    end

    # types: :splitted, :full
    def entrypoint(path: :default, entrypoint:, type: :full)
      discovery(path) if @url_discovery_map[path].nil?

      url = @url_discovery_map[path][entrypoint]
      
      if type == :full
        return url
      else
        url_splitted = url.split('/api')
      
        return [url_splitted.first, "/api#{url_splitted.last}"]
      end
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
      @connection ||= Faraday.new(url: DISCOVERY_URI) do |faraday|
        faraday.adapter(*@connection_adapter) if @connection_adapter
        faraday.adapter Faraday.default_adapter unless @connection_adapter
      end
    end
  end
end
