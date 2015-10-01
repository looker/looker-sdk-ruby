module LookerSDK

  # Authentication methods for {LookerSDK::Client}
  module Authentication

    attr_accessor :access_token_type, :access_token_expires_at

    # This is called automatically by 'request'
    def ensure_logged_in
      authenticate unless token_authenticated? || @skip_authenticate
    end

    def without_authentication
      begin
        old_skip = @skip_authenticate || false
        @skip_authenticate = true
        yield
      ensure
        @skip_authenticate = old_skip
      end
    end

    # Authenticate to the server and get an access_token for use in future calls.

    def authenticate
      raise "client_id and client_secret required" unless application_credentials?

      set_access_token_from_params(nil)
      without_authentication do
        post('/login', {}, :query => application_credentials)
        raise "login failure #{last_response.status}" unless last_response.status == 200
        set_access_token_from_params(last_response.data)
      end
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
      without_authentication do
        result = !!@access_token && ((delete('/logout') ; delete_succeeded?) rescue false)
        set_access_token_from_params(nil)
        result
      end
    end


    # Indicates if the client has OAuth Application
    # client_id and client_secret credentials
    #
    # @see look TODO docs link
    # @return Boolean
    def application_credentials?
      !!application_credentials
    end

    # Indicates if the client has an OAuth
    # access token
    #
    # @see look TODO docs link
    # @return [Boolean]
    def token_authenticated?
      !!(@access_token && (@access_token_expires_at.nil? || @access_token_expires_at > Time.now))
    end

    private

    def application_credentials
      if @client_id && @client_secret
        {
          :client_id     => @client_id,
          :client_secret => @client_secret
        }
      end
    end

    def load_credentials_from_netrc
      return unless netrc?

      require 'netrc'
      info = Netrc.read File.expand_path(netrc_file)
      netrc_host = URI.parse(api_endpoint).host
      creds = info[netrc_host]
      if creds.nil?
        # creds will be nil if there is no netrc for this end point
        looker_warn "Error loading credentials from netrc file for #{api_endpoint}"
      else
        self.client_id = creds[0]
        self.client_secret = creds[1]
      end
    rescue LoadError
      looker_warn "Please install netrc gem for .netrc support"
    end

  end
end
