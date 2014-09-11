module LookerSDK

  # Authentication methods for {LookerSDK::Client}
  module Authentication

    attr_accessor :access_token_type, :access_token_expires_at

    # This is called automatically by 'request'
    def ensure_logged_in
      authenticate unless token_authenticated? || @authenticating
    end

    # Authenticate to the server and get an access_token for use in future calls.

    def authenticate
      raise "client_id and client_secret required" unless application_authenticated?

      set_access_token_from_params(nil)
      begin
        @authenticating = true
        data = post '/login'
        raise "login failure #{last_response.status}" unless last_response.status == 200
      ensure
        @authenticating = false
      end
      set_access_token_from_params(data)
    end

    def set_access_token_from_params(params)
      reset_agent
      if params
        @access_token = params[:access_token]
        @access_token_type = params[:token_type]
        @access_token_expires_at = Time.now + params[:expires_in]
      else
        @access_token = @access_token_type = @access_token_expires_at = nil
      end
    end

    def logout
      delete '/logout' if @access_token
      set_access_token_from_params(nil)
    end


    # Indicates if the client has OAuth Application
    # client_id and client_secret credentials
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

    # Indicates if the client has an OAuth
    # access token
    #
    # @see look TODO docs link
    # @return [Boolean]
    def token_authenticated?
      !!(@access_token && (@access_token_expires_at.nil? || @access_token_expires_at > Time.now))
    end

    def load_credentials_from_netrc
      return unless netrc?

      require 'netrc'
      info = Netrc.read netrc_file
      netrc_host = URI.parse(api_endpoint).host
      creds = info[netrc_host]
      if creds.nil?
        # creds will be nil if there is no netrc for this end point
        looker_warn "Error loading credentials from netrc file for #{api_endpoint}"
      else
        self.client_id = creds.shift
        self.client_secret = creds.shift
      end
    rescue LoadError
      looker_warn "Please install netrc gem for .netrc support"
    end

  end
end
