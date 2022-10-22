# frozen_string_literal: true

require 'json'

module NubankSdk
  class Client
    def self.get_body(response)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
