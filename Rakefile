require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
Bundler::GemHelper.install_tasks

task :default => :spec

task :start_new_release do
  version = ENV['VERSION'] || 'patch'

  sh 'gem install gem-release'
  sh "gem bump --version #{version}"
  sh 'git push'

  Rake::Task[:build].invoke

  version_tag = "v#{NubankSdk::VERSION}"
  sh %W[git tag -m Version\ #{gemspec.version} #{version_tag}]
  sh 'git push --tags'
end