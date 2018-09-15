############################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2015 Looker Data Sciences, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
############################################################################################

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
    supported_rubies = ['ruby-1.9.3', 'ruby-2.0', 'ruby-2.1', 'ruby-2.3.1', 'jruby-1.7.19', 'jruby-9.1.5.0']
    failing_rubies = []

    supported_rubies.each do |ruby|
      cmd = "rvm install #{ruby} && rvm #{ruby} exec gem install bundler && rvm #{ruby} exec bundle install && rvm #{ruby} exec bundle exec rake"
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

task :default => :test
