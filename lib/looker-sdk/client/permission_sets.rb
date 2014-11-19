module LookerSDK
  class Client

    # Methods for the PermissionSets API
    #
    # @see look TODO docs link
    module PermissionSets

      # List all Looker permission_sets
      #
      # This provides a dump of every permission_set, in the order that they were created.
      #
      # @param options [Hash] Optional options. look TODO do we need options here?
      # @option options [Integer] :since The integer ID of the last PermissionSet that
      #   you’ve seen.
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker permission_sets.
      def all_permission_sets(options = {})
        paginate "permission_sets", options
      end

      # Get a single permission_set
      #
      # @param permission_set [String] A Looker permission_set id.
      # @option options [Hash] look TODO do we need options here?
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.permission_set(1)
      def permission_set(permission_set=nil, options = {})
        get "permission_sets/#{permission_set}", options
      end

      # Delete a single permission_set
      #
      # @param permission_set [String] A looker permission_set id.
      # @return [Boolean] whether or not the delete succeeded
      # @option options [Hash] look TODO do we need options here?
      # @see look TODO docs link
      # @example
      #   LookerSDK.delete_permission_set(1)
      def delete_permission_set(permission_set=nil, options = {})
        boolean_from_response :delete, "permission_sets/#{permission_set}", options
      end

      # Update a single permission_set.
      #
      # @option permission_set [String] id of permission_set to update.
      # @param options [Hash] A customizable set of options.
      # @option name [String] name for created permission_set
      # @option permissions [String, Array<String>] list of names of permissions to
      #   provide access to or string "all" to give access to all permissions
      # @option options [String] :todo look TODO: Other options for permission_set.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.update_permission_set(1, {:name => "Admin Only", :permissions => [":administer"]})
      def update_permission_set(permission_set, options = {})
        patch "permission_sets/#{permission_set}", options
      end

      # Creates a permission_set
      #
      # @option options [Hash] A customizable set of options.
      # @option name [String] name for created permission_set
      # @option permissions [String, Array<String>] list of names of permissions to
      #   provide access to or string "all" to give access to all permissions
      # @option options [String] :todo look TODO: Other options for permission_set.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.create_permission_set({:name => "Games", :permissions => ["zelda", "supersmash"]})
      #   LookerSDK.create_permission_set({:name => "every_model", :permissions => "all"})
      def create_permission_set(options = {})
        post 'permission_sets', options
      end

      # List all roles associated with a permission_set
      #
      # This provides a list of the roles that a permission_set has.
      #
      # @param permission_set [Integer] PermissionSet id.
      # @param options [Hash] Optional options. look TODO do we need options here?
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker Roles associated with a permission_set.
      # @example
      #   LookerSDK.roles(1)
      def permission_set_roles(permission_set, options = {})
        paginate "permission_sets/#{permission_set}/roles", options
      end
    end

  end
end
