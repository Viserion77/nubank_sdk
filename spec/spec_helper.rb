# frozen_string_literal: true

require 'simplecov'
require "simplecov-json"

SimpleCov.minimum_coverage 100
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])
SimpleCov.start do
  enable_coverage :branch
  primary_coverage :branch
  track_files "lib/**/*.rb"
  add_filter "/spec/"
end
SimpleCov.at_exit do
  puts "Coverage done"
  SimpleCov.result.format!
end

require 'bundler/setup'
require 'nubank_sdk'
require 'factory_bot'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
