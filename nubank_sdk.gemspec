# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nubank_sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'nubank_sdk'
  spec.version       = NubankSdk::VERSION
  spec.authors       = ['Viserion77']
  spec.email         = ['jeferson.a.oficial@gmail.com']

  spec.summary       = 'A gem to make it ease to monitorize your Nubank account.'
  spec.description   = 'Monitorize balances, recent transactions, credit limit etc...'
  spec.homepage      = 'https://github.com/Viserion77/nubank_sdk'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.3.26'
  spec.add_development_dependency 'factory_bot', '~> 6.2.1'
  spec.add_development_dependency 'gem-release', '~> 2.2.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.41.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.16.0'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
  spec.add_development_dependency 'simplecov-json', '~> 0.2.3'
  spec.add_development_dependency 'solargraph'
  spec.add_development_dependency 'yard', '~> 0.9.12'

  spec.add_dependency 'faraday', '~> 2.7.1'
  spec.add_dependency 'json', '~> 2.3'
end
