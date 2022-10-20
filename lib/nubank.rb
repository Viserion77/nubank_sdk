require "nubank/version"

module Nubank
  class Error < StandardError; end
  
  class Connection
    def connected?
      true
    end
  end
end
