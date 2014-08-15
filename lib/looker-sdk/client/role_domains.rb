module LookerSDK
  class Client

    # Methods for the RoleDomains API
    #
    # @see look TODO docs link
    module RoleDomains

      # List all Looker role_domains
      #
      # This provides a dump of every role_domain, in the order that they signed up
      # for Looker.
      #
      # @param options [Hash] Optional options. look TODO do we need options here?
      # @option options [Integer] :since The integer ID of the last RoleDomain that
      #   you’ve seen.
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker role_domains.
      def all_role_domains(options = {})
        paginate "role_domains", options
      end

      # Get a single role_domain
      #
      # @param role_domain [String] A Looker role_domain id.
      # @option options [Hash] look TODO do we need options here?
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.role_domain(1)
      def role_domain(role_domain=nil, options = {})
        get "role_domains/#{role_domain}", options
      end

      # Delete a single role_domain
      #
      # @param role_domain [String] A looker role_domain id.
      # @return [Boolean] whether or not the delete succeeded
      # @option options [Hash] look TODO do we need options here?
      # @see look TODO docs link
      # @example
      #   LookerSDK.delete_role_domain(1)
      def delete_role_domain(role_domain=nil, options = {})
        boolean_from_response :delete, "role_domains/#{role_domain}", options
      end

      # Update a single role_domain.
      #
      # @option role_domain [String] id of role_domain to update.
      # @param options [Hash] A customizable set of options.
      # @option name [String] name for created role_domain
      # @option models [String, Array<String>] list of names of models to
      #   provide access to or string "all" to give access to all models
      # @option options [String] :todo look TODO: Other options for role_domain.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.update_role_domain(1, {:name => "Marketing", :models => ["business"]})
      def update_role_domain(role_domain, options = {})
        patch "role_domains/#{role_domain}", options
      end

      # Creates a role_domain
      #
      # @option options [Hash] A customizable set of options.
      # @option name [String] name for created role_domain
      # @option models [String, Array<String>] list of names of models to
      #   provide access to or string "all" to give access to all models
      # @option options [String] :todo look TODO: Other options for role_domain.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.create_role_domain({:name => "Games", :models => ["zelda", "supersmash"]})
      #   LookerSDK.create_role_domain({:name => "every_model", :models => "all"})
      def create_role_domain(options = {})
        post 'role_domains', options
      end

      # List all roles associated with a role_domain
      #
      # This provides a list of the roles that a role_domain has.
      #
      # @param role_domain [Integer] RoleDomain id.
      # @param options [Hash] Optional options. look TODO do we need options here?
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker Roles associated with a role_domain.
      # @example
      #   LookerSDK.roles(1)
      def role_domain_roles(role_domain, options = {})
        paginate "role_domains/#{role_domain}/roles", options
      end
    end

    private
    # convenience method for constructing a role_domain specific path, if the role_domain is logged in
    def role_domain_path(role_domain, path)
      if role_domain == login && role_domain_authenticated?
        "role_domain/#{path}"
      else
        "role_domains/#{role_domain}/#{path}"
      end
    end
  end
end
