require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
Bundler::GemHelper.install_tasks

task :default => :spec

task :start_new_release do
  bump = ENV['BUMP'] || 'patch'

  sh 'gem install gem-release'
  sh "gem bump --version #{bump}"
  
  sh 'bundle'
  Rake::Task[:build].invoke
  
  sh 'git add .'
  sh "git commit -m \"build(version): :bookmark: bump #{bump}\"" 
  sh 'git push'

  version = NubankSdk::VERSION
  version_tag = "v#{version}"
  sh "git tag -a #{version_tag} -m \"Version #{version}\""
  sh 'git push --tags'
end