# vim: set expandtab sw=2 ts=2:ft=ruby
# To test and build the gem:
#   bundle exec rake
# To run rubocop:
#   bundle exec rake cop
# To test only:
#   bundler exec rake test
# To clean up the .gem files:
#   bundle exec rake clobber
#
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:test)

task :default => [ :cop, :test, :build ]

desc 'run rubocop'
task :cop do
  sh 'bundle exec rubocop bin/pwqgen lib/*.rb lib/pwqgen/*.rb'
end
