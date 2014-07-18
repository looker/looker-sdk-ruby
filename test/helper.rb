require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start

require 'json'
require 'looker-sdk'
require 'minitest/autorun'
require 'minitest/spec'
require "webmock"
require 'vcr'
require "minitest-vcr"

VCR.configure do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/cassettes"
  c.hook_into :webmock
end

MinitestVcr::Spec.configure!

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end
