module Looker

  # Configuration options for {Client}, defaulting to values
  # in {Default}
  module Configurable
    # @!attribute [w] access_token
    # @see look TODO docs link
    #   @return [String] OAuth2 access token for authentication
    # @!attribute api_endpoint
    #   @return [String] Base URL for API requests. default: https://api.looker.com/ look TODO: this is the wrong url... what's the right one?  Also update all other references to "api.looker.com"
    # @!attribute auto_paginate
    #   @return [Boolean] Auto fetch next page of results until rate limit reached
    # @!attribute client_id
    # @see look TODO docs link
    #   @return [String] Configure OAuth app key
    # @!attribute [w] client_secret
    # @see look TODO docs link
    #   @return [String] Configure OAuth app secret
    # @!attribute default_media_type
    # @see look TODO docs link
    #   @return [String] Configure preferred media type (for API versioning, for example)
    # @!attribute connection_options
    #   @see https://github.com/lostisland/faraday
    #   @return [Hash] Configure connection options for Faraday
    # @!attribute login
    #   @return [String] Looker username for Basic Authentication
    # @!attribute middleware
    #   @see https://github.com/lostisland/faraday
    #   @return [Faraday::Builder or Faraday::RackBuilder] Configure middleware for Faraday
    # @!attribute netrc
    #   @return [Boolean] Instruct Looker to get credentials from .netrc file
    # @!attribute netrc_file
    #   @return [String] Path to .netrc file. default: ~/.netrc
    # @!attribute [w] password
    #   @return [String] Looker password for Basic Authentication
    # @!attribute per_page
    #   @return [String] Configure page size for paginated results. API default: 30
    # @!attribute proxy
    #   @see https://github.com/lostisland/faraday
    #   @return [String] URI for proxy server
    # @!attribute user_agent
    #   @return [String] Configure User-Agent header for requests.
    # @!attribute web_endpoint
    #   @return [String] Base URL for web URLs. default: https://<client>.looker.com/ look TODO is this correct?

    attr_accessor :access_token, :auto_paginate, :client_id,
                  :client_secret, :default_media_type, :connection_options,
                  :middleware, :netrc, :netrc_file,
                  :per_page, :proxy, :user_agent
    attr_writer :password, :web_endpoint, :api_endpoint, :login

    class << self

      # List of configurable keys for {Looker::Client}
      # @return [Array] of option keys
      def keys
        @keys ||= [
          :access_token,
          :api_endpoint,
          :auto_paginate,
          :client_id,
          :client_secret,
          :connection_options,
          :default_media_type,
          :login,
          :middleware,
          :netrc,
          :netrc_file,
          :per_page,
          :password,
          :proxy,
          :user_agent,
          :web_endpoint
        ]
      end
    end

    # Set configuration options using a block
    def configure
      yield self
    end

    # Reset configuration options to default values
    def reset!
      Looker::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Looker::Default.options[key])
      end
      self
    end
    alias setup reset!

    def api_endpoint
      File.join(@api_endpoint, "")
    end

    # Base URL for generated web URLs
    #
    # @return [String] Default: https://<client>.looker.com/ look TODO is this correct?
    def web_endpoint
      File.join(@web_endpoint, "")
    end

    def login
      @login ||= begin
        user.login if token_authenticated?
      end
    end

    def netrc?
      !!@netrc
    end

    private

    def options
      Hash[Looker::Configurable.keys.map{|key| [key, instance_variable_get(:"@#{key}")]}]
    end

    def fetch_client_id_and_secret(overrides = {})
      opts = options.merge(overrides)
      opts.values_at :client_id, :client_secret
    end
  end
end
