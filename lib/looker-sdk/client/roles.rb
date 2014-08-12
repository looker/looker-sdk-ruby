module LookerSDK
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
      #   LookerSDK.role(1)
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
      #   LookerSDK.delete_role(1)
      def delete_role(role_id, options = {})
        boolean_from_response :delete, "roles/#{role_id}", options
      end

      # Update a role.
      #
      # @option role_id [Integer] id of role to update.
      # @param options [Hash] A customizable set of options.
      # @option name [String] :name for role
      # @option role_type_id [Integer] :role_type_id for role
      # @option domain_id [Integer] :domain_id for role
      # @option options [String] :todo look TODO: Other options for role.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.update_role(1, :name => "new_role", :domain_id => domain.id, :role_type_id => role_type.id)
      def update_role(role_id, options = {})
        patch "roles/#{role_id}", options
      end

      # Create a role.
      #
      # @param options [Hash] A customizable set of options.
      # @option options [String] :models
      # @option name [String] :name for new role
      # @option role_type_id [Integer] :role_type_id for new role
      # @option domain_id [Integer] :domain_id for new role
      # @option options [String] :todo look TODO: Other options for role.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.create_role(:name => "new_role", :domain_id => domain.id, :role_type_id => role_type.id)
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
      #   LookerSDK.role_users(1)
      def role_users(role_id, options = {})
        paginate "roles/#{role_id}/users", options
      end

      # Add set users of role
      #
      # @param role_id [Integer] Role id.
      # @param users [Array<Integer>] Ids of new users.
      # @return [Sawyer::Resource] all users that exist in updated role.
      # @see look TODO docs link
      # @example
      #   LookerSDK.set_role_users(1, [1, 3, 5])
      def set_role_users(role_id, users, options = {})
        put "roles/#{role_id}/users", options.merge(:users => users)
      end
    end

  end
end
