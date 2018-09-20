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

require 'rubygems'
require 'bundler/setup'

require 'looker-sdk.rb'
require 'pry'

def sdk
  @sdk ||= LookerSDK::Client.new(
    # Create your own API3 key and add it to a .netrc file in your location of choice.
    :netrc      => true,
    :netrc_file => "./.netrc",

    # Disable cert verification if the looker has a self-signed cert.
    # :connection_options => {:ssl => {:verify => false}},

    # Support self-signed cert *and* set longer timeout to allow for long running queries.
    :connection_options => {:ssl => {:verify => false}, :request => {:timeout => 60 * 60, :open_timeout => 30}},

    :api_endpoint => "https://localhost:19999/api/3.0",

    # Customize to use your specific looker instance
    # :connection_options => {:ssl => {:verify => true}},
    # :api_endpoint => "https://looker.mycoolcompany.com:19999/api/3.0",
  )
end

begin
  puts "Connecting to Looker at '#{sdk.api_endpoint}'"
  puts sdk.alive? ? "Looker is alive!" : "Sad Looker, can't connect:\n  #{sdk.last_error}"
  puts sdk.authenticated? ? "Authenticated!" : "Sad Looker, can't authenticate:\n  #{sdk.last_error}"

  binding.pry self
rescue Exception => e
  puts e
ensure
  puts 'Bye!'
end

