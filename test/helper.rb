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

def fix_netrc_permissions(path)
  s = File.stat(path)
  raise "'#{path}'' not a file" unless s.file?
  File.chmod(0600, path) unless s.mode.to_s(8)[3..5] == "0600"
end

fix_netrc_permissions(File.join(fixture_path, '.netrc'))

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


