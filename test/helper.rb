require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start

require 'json'
require 'looker-sdk'
require 'minitest/autorun'
require 'minitest/spec'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

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


