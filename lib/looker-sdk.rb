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

require 'faraday'
# The Faraday autoload scheme is supposed to work to load other dependencies on demand.
# It does work, but there are race condition problems upon first load of a given file
# that have caused intermittent failures in our ruby and integration tests - and could bite in production.
# The simple/safe solution is to just pre-require these parts that are actually used
# by the looker-sdk to prevent a race condition later.
# See https://github.com/lostisland/faraday/issues/181
# and https://bugs.ruby-lang.org/issues/921
require 'faraday/autoload'
require 'faraday/adapter'
require 'faraday/adapter/rack'
require 'faraday/adapter/net_http'
require 'faraday/connection'
require 'faraday/error'
require 'faraday/middleware'
require 'faraday/options'
require 'faraday/parameters'
require 'faraday/rack_builder'
require 'faraday/request'
require 'faraday/request/authorization'
require 'faraday/response'
require 'faraday/utils'

#require 'rack'
#require 'rack/mock_response'

require 'looker-sdk/client'
require 'looker-sdk/default'

module LookerSDK

  class << self
    include LookerSDK::Configurable

    # API client based on configured options {Configurable}
    #
    # @return [LookerSDK::Client] API wrapper
    def client
      @client = LookerSDK::Client.new(options) unless defined?(@client) && @client.same_options?(options)
      @client
    end

    # @private
    def respond_to_missing?(method_name, include_private=false); client.respond_to?(method_name, include_private); end if RUBY_VERSION >= "1.9"
    # @private
    def respond_to?(method_name, include_private=false); client.respond_to?(method_name, include_private) || super; end if RUBY_VERSION < "1.9"

  private

    def method_missing(method_name, *args, &block)
      return super unless client.respond_to?(method_name)
      client.send(method_name, *args, &block)
    end

  end
end

LookerSDK.setup
