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

require 'looker-sdk/response/raise_error'
require 'looker-sdk/version'

module LookerSDK

  # Default configuration options for {Client}
  module Default

    # Default API endpoint look TODO update this as needed
    API_ENDPOINT = "https://localhost:19999/api/3.0/".freeze

    # Default User Agent header string
    USER_AGENT   = "Looker Ruby Gem #{LookerSDK::VERSION}".freeze

    # Default media type
    MEDIA_TYPE   = "application/json"

    # Default WEB endpoint
    WEB_ENDPOINT = "https://localhost:9999".freeze # look TODO update this

    # In Faraday 0.9, Faraday::Builder was renamed to Faraday::RackBuilder
    RACK_BUILDER_CLASS = defined?(Faraday::RackBuilder) ? Faraday::RackBuilder : Faraday::Builder

    # Default Faraday middleware stack
    MIDDLEWARE = RACK_BUILDER_CLASS.new do |builder|
      builder.use LookerSDK::Response::RaiseError
      builder.adapter Faraday.default_adapter
    end

    class << self

      # Configuration options
      # @return [Hash]
      def options
        Hash[LookerSDK::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # Default access token from ENV
      # @return [String]
      def access_token
        ENV['LOOKER_ACCESS_TOKEN']
      end

      # Default API endpoint from ENV or {API_ENDPOINT}
      # @return [String]
      def api_endpoint
        ENV['LOOKER_API_ENDPOINT'] || API_ENDPOINT
      end

      # Default pagination preference from ENV
      # @return [String]
      def auto_paginate
        ENV['LOOKER_AUTO_PAGINATE']
      end

      # Default OAuth app key from ENV
      # @return [String]
      def client_id
        ENV['LOOKER_CLIENT_ID']
      end

      # Default OAuth app secret from ENV
      # @return [String]
      def client_secret
        ENV['LOOKER_SECRET']
      end

      # Default options for Faraday::Connection
      # @return [Hash]
      def connection_options
        {
          :headers => {
            :accept => default_media_type,
            :user_agent => user_agent
          }
        }
      end

      # Default media type from ENV or {MEDIA_TYPE}
      # @return [String]
      def default_media_type
        ENV['LOOKER_DEFAULT_MEDIA_TYPE'] || MEDIA_TYPE
      end

      # Default middleware stack for Faraday::Connection
      # from {MIDDLEWARE}
      # @return [String]
      def middleware
        MIDDLEWARE
      end

      def faraday
        nil
      end

      def swagger
        nil
      end

      def shared_swagger
        false
      end

      # Default behavior for loading swagger during initialization or at first call
      # @return [Boolean]
      def lazy_swagger
        false
      end

      def raw_responses
        false
      end

      # Default pagination page size from ENV
      # @return [Fixnum] Page size
      def per_page
        page_size = ENV['LOOKER_PER_PAGE']

        page_size.to_i if page_size
      end

      # Default proxy server URI for Faraday connection from ENV
      # @return [String]
      def proxy
        ENV['LOOKER_PROXY']
      end

      # Default User-Agent header string from ENV or {USER_AGENT}
      # @return [String]
      def user_agent
        ENV['LOOKER_USER_AGENT'] || USER_AGENT
      end

      # Default web endpoint from ENV or {WEB_ENDPOINT}
      # @return [String]
      def web_endpoint
        ENV['LOOKER_WEB_ENDPOINT'] || WEB_ENDPOINT
      end

      # Default behavior for reading .netrc file
      # @return [Boolean]
      def netrc
        ENV['LOOKER_NETRC'] || false
      end

      # Default path for .netrc file
      # @return [String]
      def netrc_file
        ENV['LOOKER_NETRC_FILE'] || File.join(ENV['HOME'].to_s, '.netrc')
      end

    end
  end
end
