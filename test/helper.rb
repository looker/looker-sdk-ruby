require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start

require 'rubygems'
require 'bundler/setup'

require 'ostruct'
require 'json'
require 'looker-sdk'

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/mock'
require 'mocha/mini_test'
require "rack/test"
require "rack/request"

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

# Using this prefix consistently makes it easier to find any crap that might get left behind
# in the looker db when tests fail or are written poorly.
# Note that looker has a rake task to do that cleanup automatically.

SDK_OBJECT_PREFIX = '_SDK_TEST_'.freeze

def mk_name(name)
  "#{SDK_OBJECT_PREFIX}#{name}"
end

def setup_sdk
  LookerSDK.reset!
  LookerSDK.configure do |c|
    c.connection_options = {:ssl => {:verify => false}}
    c.netrc = true
    c.netrc_file =  File.join(fixture_path, '.netrc')
  end
end

def teardown_sdk
  LookerSDK.logout
end


