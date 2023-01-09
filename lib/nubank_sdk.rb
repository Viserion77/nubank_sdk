# frozen_string_literal: true

require 'nubank_sdk/account'
require 'nubank_sdk/api_routes'
require 'nubank_sdk/auth'
require 'nubank_sdk/certificate'
require 'nubank_sdk/credit'
require 'nubank_sdk/client'
require 'nubank_sdk/user'
require 'nubank_sdk/version'

module NubankSdk
  class Error < StandardError; end
end
