module LookerSDK

  # Authentication methods for {LookerSDK::Client}
  module Authentication

    attr_accessor :access_token_type, :access_token_expires_at

    # Authenticate to the server and get an access_token for use in future calls.

    # Uses passed in credentials or fallsback to other credentials as appropriate.
    # This allows for using the .netrc to manage the login credentials
    def authenticate(client_id=nil, secret=nil)
      unless client_id && secret
        if basic_authenticated?
          client_id = @login
          secret = @password
        elsif application_authenticated?
          client_id = @client_id
          secret = @client_secret
        else
          raise "client_id and secret required"
        end
      end

      # clear any other credentials
      @login = @client_id = nil
      @password = @client_secret = nil
      reset_agent

      data = post '/login', {:query => {:client_id => client_id, :secret => secret}}
      raise "login failure #{last_response.status}" unless last_response.status == 200

      reset_agent
      @access_token = data[:access_token]
      @access_token_type = data[:token_type]
      @access_token_expires_at = Time.now + data[:expires_in]
    end

    # Indicates if the client was supplied  Basic Auth
    # username and password
    #
    # @see look TODO docs link
    # @return [Boolean]
    def basic_authenticated?
      !!(@login && @password)
    end

    # Indicates if the client was supplied an OAuth
    # access token
    #
    # @see look TODO docs link
    # @return [Boolean]
    def token_authenticated?
      !!@access_token
    end

    # Indicates if the client was supplied an OAuth
    # access token or Basic Auth username and password
    #
    # @see look TODO docs link
    # @return [Boolean]
    def user_authenticated?
      basic_authenticated? || token_authenticated?
    end

    # Indicates if the client has OAuth Application
    # client_id and secret credentials to make anonymous
    # requests at a higher rate limit
    #
    # @see look TODO docs link
    # @return Boolean
    def application_authenticated?
      !!application_authentication
    end

    private

    def application_authentication
      if @client_id && @client_secret
        {
          :client_id     => @client_id,
          :client_secret => @client_secret
        }
      end
    end

    def login_from_netrc
      return unless netrc?

      require 'netrc'
      info = Netrc.read netrc_file
      netrc_host = URI.parse(api_endpoint).host
      creds = info[netrc_host]
      if creds.nil?
        # creds will be nil if there is no netrc for this end point
        looker_warn "Error loading credentials from netrc file for #{api_endpoint}"
      else
        self.login = creds.shift
        self.password = creds.shift
      end
    rescue LoadError
      looker_warn "Please install netrc gem for .netrc support"
    end

  end
end
