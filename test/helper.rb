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

begin
  require 'zlib'
  require 'stringio'
  have_zlib = true
rescue LoadError
  have_zlib = false
end

VCR.configure do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/cassettes"
  c.hook_into :webmock

  # human readable cassettes
  c.before_record do |i|
    if have_zlib and enc = i.response.headers['Content-Encoding'] and 'gzip' == Array(enc).first
      i.response.body = Zlib::GzipReader.new(StringIO.new(i.response.body)).read
      i.response.update_content_length_header
      i.response.headers.delete 'Content-Encoding'
    end
  end
end

MinitestVcr::Spec.configure!

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end
