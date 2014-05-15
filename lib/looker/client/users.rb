module Looker
  class Client

    # Methods for the Users API
    #
    # @see look TODO docs link
    module Users

      # List all Looker users
      #
      # This provides a dump of every user, in the order that they signed up
      # for Looker.
      #
      # @param options [Hash] Optional options.
      # @option options [Integer] :since The integer ID of the last User that
      #   you’ve seen.
      #
      # @see https://developer.looker.com/3.0/users/#get-all-users
      #
      # @return [Array<Sawyer::Resource>] List of Looker users.
      def all_users(options = {})
        paginate "users", options
      end

      # Get a single user
      #
      # @param user [String] A Looker user id.
      # @return [Sawyer::Resource]
      # @see https://developer.looker.com/3.0/users/#get-a-single-user
      # @see https://developer.looker.com/3.0/users/#get-the-authenticated-user
      # @example
      #   Looker.user(1)
      def user(user=nil, options = {})
        if user
          get "users/#{user}", options
        else
          get 'user', options
        end
      end
    end

    private
    # convenience method for constructing a user specific path, if the user is logged in
    def user_path(user, path)
      if user == login && user_authenticated?
        "user/#{path}"
      else
        "users/#{user}/#{path}"
      end
    end
  end
end
