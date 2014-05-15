require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start

require 'json'
require 'looker'
require 'minitest/autorun'
require 'minitest/spec'
require 'vcr'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end
