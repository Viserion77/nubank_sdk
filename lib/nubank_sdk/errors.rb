# frozen_string_literal: true

module NubankSdk
  class Errors < StandardError
    class InvalidEncryptedCode < StandardError; end
  end
end
