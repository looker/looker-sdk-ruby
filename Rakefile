require 'bundler'
require "bundler/gem_tasks"

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/test_*.rb"]
  t.verbose = true
end

namespace :test do
  desc "Run tests against all supported Rubies"
  task :all do
    supported_rubies = ['ruby-1.9', 'ruby-2.0', 'ruby-2.1', 'jruby-1.7.11', 'jruby-1.7.12']
    failing_rubies = []

    supported_rubies.each do |ruby|
      cmd = "rvm install #{ruby} && rvm #{ruby} exec bundle install && rvm #{ruby} exec bundle exec rake"
      system cmd
      if $? != 0
        failing_rubies << ruby
      end
    end

    failing_rubies.each do |ruby|
      puts "FAIL: #{ruby}.  Problem with the tests on #{ruby}."
    end

    if failing_rubies
      exit 1
    else
      exit 0
    end
  end
end

namespace :doc do
  require 'yard'
  YARD::Rake::YardocTask.new do |task|
    task.files   = ['README.md', 'LICENSE.md', 'lib/**/*.rb']
    task.options = [
        '--output-dir', 'doc/yard',
        '--markup', 'markdown',
    ]
  end
end

task :default => :test
