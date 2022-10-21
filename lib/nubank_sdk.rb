require "nubank_sdk/version"

module NubankSdk
  class Error < StandardError; end
  
  class Connection
    def connected?
      true
    end
  end
end
