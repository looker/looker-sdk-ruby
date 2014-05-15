require 'faraday'
require 'looker/error'

module Looker
  # Faraday response middleware
  module Response

    # HTTP status codes returned by the API
    class RaiseError < Faraday::Response::Middleware

      private

      def on_complete(response)
        if error = Looker::Error.from_response(response)
          raise error
        end
      end
    end
  end
end
