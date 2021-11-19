############################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2018 Looker Data Sciences, Inc.
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

begin
  fix_netrc_permissions(File.join(fixture_path, '.netrc'))
rescue => e
  puts e
end

def setup_sdk
  LookerSDK.reset!

  base_url = ENV['LOOKERSDK_BASE_URL'] || 'https://localhost:20000'
  verify_ssl = case ENV['LOOKERSDK_VERIFY_SSL']
               when /false/i
                 false
               when /f/i
                 false
               when '0'
                 false
               else
                 true
               end
  api_version = ENV['LOOKERSDK_API_VERSION'] || '4.0'
  client_id = ENV['LOOKERSDK_CLIENT_ID']
  client_secret = ENV['LOOKERSDK_CLIENT_SECRET']

  LookerSDK.configure do |c|
    c.lazy_swagger = true
    c.connection_options = {:ssl => {:verify => false}} unless verify_ssl
    if (client_id && client_secret) then
      c.client_id = client_id
      c.client_secret = client_secret
      c.api_endpoint = "#{base_url}/api/#{api_version}"
    else
      c.netrc = true
      c.netrc_file =  File.join(fixture_path, '.netrc')
    end
  end
end

def teardown_sdk
  setup_sdk  # put back initial config
  LookerSDK.logout
end
