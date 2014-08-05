module Looker
  class Client

    # Methods for the Roles API
    #
    # @see look TODO docs link
    module Roles

      # List all Looker roles
      #
      # This provides a dump of every role
      #
      # @param options [Hash] Optional options. look TODO do we need options here?
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker roles.
      def all_roles(options = {})
        paginate "roles", options
      end

      # Get a single role
      #
      # @param role_id [String] A Looker user id.
      # @option options [Hash] look TODO do we need options here?
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   Looker.role(1)
      def role(role_id, options = {})
        get "roles/#{role_id}", options
      end

      # Delete a role
      #
      # @param role_id [Integer] A looker role id.
      # @return [Boolean] whether or not the delete succeeded
      # @option options [Hash] look TODO do we need options here?
      # @see look TODO docs link
      # @example
      #   Looker.delete_role(1)
      def delete_role(role_id, options = {})
        boolean_from_response :delete, "roles/#{role_id}", options
      end

      # Update a role.
      #
      # @option role_id [Integer] id of role to update.
      # @param options [Hash] A customizable set of options.
      # @option options [String] :todo look TODO: Other options for role.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   Looker.update_role(1, {:models => "ALL", :permissions => ["see_looks", "access_data"]})
      def update_role(role_id, options = {})
        patch "roles/#{role_id}", options
      end

      # Create a role.
      #
      # @option user [String] id of user to update.
      # @param options [Hash] A customizable set of options.
      # @option options [String] :models
      # @option options [Array<String>] :permissions
      # @option options [String] :todo look TODO: Other options for role.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   Looker.create_role({:models => "ALL", :permissions => ["see_looks", "access_data"]})
      def create_role(options = {})
        post 'roles', options
      end

      # List all users associated with a role
      #
      # This provides a list of the users that a role has.
      #
      # @param role_id [Integer] Role id.
      # @param options [Hash] Optional options. look TODO do we need options here?
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker Users associated with a role.
      # @example
      #   Looker.role_users(1)
      def role_users(role_id, options = {})
        paginate "roles/#{role_id}/users", options
      end

      # Add user to role
      #
      # @param role_id [Integer] Role id.
      # @param user [Integer] Id of new user.
      # @return [Boolean] True on successful addition, false otherwise.
      # @see look TODO docs link
      # @example
      #   Looker.add_role_user(1, 1)
      def add_role_user(role_id, user, options = {})
        boolean_from_response :put, "roles/#{role_id}/users/#{user}", options
      end

      # Remove user from role.
      #
      # @param role_id [Integer] Role id.
      # @param user [Integer] Id of user to remove
      # @return [Boolean] True if user removed, false otherwise.
      # @see look TODO docs link
      # @example
      #   Looker.remove_role_user(1, 1)
      def remove_role_user(role_id, user, options = {})
        boolean_from_response :delete, "roles/#{role_id}/users/#{user}", options
      end
    end

  end
end
