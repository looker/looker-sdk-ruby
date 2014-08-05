module Looker
  class Client

    # Methods for the Domains API
    #
    # @see look TODO docs link
    module Domains

      # List all Looker domains
      #
      # This provides a dump of every domain, in the order that they signed up
      # for Looker.
      #
      # @param options [Hash] Optional options. look TODO do we need options here?
      # @option options [Integer] :since The integer ID of the last Domain that
      #   you’ve seen.
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker domains.
      def all_domains(options = {})
        paginate "domains", options
      end

      # Get a single domain
      #
      # @param domain [String] A Looker domain id.
      # @option options [Hash] look TODO do we need options here?
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   Looker.domain(1)
      def domain(domain=nil, options = {})
        get "domains/#{domain}", options
      end

      # Delete a single domain
      #
      # @param domain [String] A looker domain id.
      # @return [Boolean] whether or not the delete succeeded
      # @option options [Hash] look TODO do we need options here?
      # @see look TODO docs link
      # @example
      #   Looker.delete_domain(1)
      def delete_domain(domain=nil, options = {})
        boolean_from_response :delete, "domains/#{domain}", options
      end

      # Update a single domain.
      #
      # @option domain [String] id of domain to update.
      # @param options [Hash] A customizable set of options.
      # @option name [String] name for created domain
      # @option models [String, Array<String>] list of names of models to
      #   provide access to or string "all" to give access to all models
      # @option options [String] :todo look TODO: Other options for domain.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   Looker.update_domain(1, {:name => "Marketing", :models => ["business"]})
      def update_domain(domain, options = {})
        patch "domains/#{domain}", options
      end

      # Creates a domain
      #
      # @option options [Hash] A customizable set of options.
      # @option name [String] name for created domain
      # @option models [String, Array<String>] list of names of models to
      #   provide access to or string "all" to give access to all models
      # @option options [String] :todo look TODO: Other options for domain.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   Looker.create_domain({:name => "Games", :models => ["zelda", "supersmash"]})
      #   Looker.create_domain({:name => "every_model", :models => "all"})
      def create_domain(options = {})
        post 'domains', options
      end

      # List all roles associated with a domain
      #
      # This provides a list of the roles that a domain has.
      #
      # @param domain [Integer] Domain id.
      # @param options [Hash] Optional options. look TODO do we need options here?
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker Roles associated with a domain.
      # @example
      #   Looker.roles(1)
      def domain_roles(domain, options = {})
        paginate "domains/#{domain}/roles", options
      end
    end

    private
    # convenience method for constructing a domain specific path, if the domain is logged in
    def domain_path(domain, path)
      if domain == login && domain_authenticated?
        "domain/#{path}"
      else
        "domains/#{domain}/#{path}"
      end
    end
  end
end
