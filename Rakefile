require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
Bundler::GemHelper.install_tasks

task :default => :spec

task :gem_bump do
  version = ENV['VERSION'] || 'patch'

  sh 'gem install gem-release'
  sh "gem bump --version #{version}"
  sh 'git push'
end