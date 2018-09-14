###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

require 'faraday'
require 'looker-sdk/error'

module LookerSDK
  # Faraday response middleware
  module Response

    # HTTP status codes returned by the API
    class RaiseError < Faraday::Response::Middleware

      private

      def on_complete(response)
        if error = LookerSDK::Error.from_response(response)
          raise error
        end
      end
    end
  end
end
