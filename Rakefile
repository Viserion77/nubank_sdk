# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
Bundler::GemHelper.install_tasks

task default: :spec

task :start_new_release do
  bump = ENV['BUMP'] || 'patch'

  sh "gem bump --version #{bump}"

  sh 'bundle'
  Rake::Task[:build].invoke

  sh 'git add .'
  sh "git commit -m \"build(version): :bookmark: bump #{bump}\""
  sh 'git push'
end

task :generate_git_tag do
  version = NubankSdk::VERSION
  version_tag = "v#{version}"
  sh "git tag -a #{version_tag} -m \"Version #{version}\""
  sh 'git push --tags'
end

task :build_local do
  version = NubankSdk::VERSION
  sh 'gem uninstall nubank_sdk'
  sh 'rm nubank_sdk-*.gem' if File.exist?("nubank_sdk-#{version}.gem")
  sh 'gem build nubank_sdk.gemspec'
  sh "gem install --local nubank_sdk-#{version}.gem"
end
