module Looker
  class Client

    # Methods for the RoleTypes API
    #
    # @see look TODO docs link
    module RoleTypes

      # List all Looker role_types
      #
      # This provides a dump of every role_type, in the order that they signed up
      # for Looker.
      #
      # @param options [Hash] Optional options. look TODO do we need options here?
      # @option options [Integer] :since The integer ID of the last RoleType that
      #   you’ve seen.
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker role_types.
      def all_role_types(options = {})
        paginate "role_types", options
      end

      # Get a single role_type
      #
      # @param role_type [String] A Looker role_type id.
      # @option options [Hash] look TODO do we need options here?
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   Looker.role_type(1)
      def role_type(role_type=nil, options = {})
        get "role_types/#{role_type}", options
      end

      # Delete a single role_type
      #
      # @param role_type [String] A looker role_type id.
      # @return [Boolean] whether or not the delete succeeded
      # @option options [Hash] look TODO do we need options here?
      # @see look TODO docs link
      # @example
      #   Looker.delete_role_type(1)
      def delete_role_type(role_type=nil, options = {})
        boolean_from_response :delete, "role_types/#{role_type}", options
      end

      # Update a single role_type.
      #
      # @option role_type [String] id of role_type to update.
      # @param options [Hash] A customizable set of options.
      # @option name [String] name for created role_type
      # @option permissions [String, Array<String>] list of names of permissions to
      #   provide access to or string "all" to give access to all permissions
      # @option options [String] :todo look TODO: Other options for role_type.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   Looker.update_role_type(1, {:name => "Admin Only", :permissions => [":administer"]})
      def update_role_type(role_type, options = {})
        patch "role_types/#{role_type}", options
      end

      # Creates a role_type
      #
      # @option options [Hash] A customizable set of options.
      # @option name [String] name for created role_type
      # @option permissions [String, Array<String>] list of names of permissions to
      #   provide access to or string "all" to give access to all permissions
      # @option options [String] :todo look TODO: Other options for role_type.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   Looker.create_role_type({:name => "Games", :permissions => ["zelda", "supersmash"]})
      #   Looker.create_role_type({:name => "every_model", :permissions => "all"})
      def create_role_type(options = {})
        post 'role_types', options
      end

      # List all roles associated with a role_type
      #
      # This provides a list of the roles that a role_type has.
      #
      # @param role_type [Integer] RoleType id.
      # @param options [Hash] Optional options. look TODO do we need options here?
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker Roles associated with a role_type.
      # @example
      #   Looker.roles(1)
      def role_type_roles(role_type, options = {})
        paginate "role_types/#{role_type}/roles", options
      end
    end

    private
    # convenience method for constructing a role_type specific path, if the role_type is logged in
    def role_type_path(role_type, path)
      if role_type == login && role_type_authenticated?
        "role_type/#{path}"
      else
        "role_types/#{role_type}/#{path}"
      end
    end
  end
end
