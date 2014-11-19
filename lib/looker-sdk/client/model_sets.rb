module LookerSDK
  class Client

    # Methods for the ModelSets API
    #
    # @see look TODO docs link
    module ModelSets

      # List all Looker model_sets
      #
      # This provides a dump of every model_set in the order that they were created.
      #
      # @param options [Hash] Optional options. look TODO do we need options here?
      # @option options [Integer] :since The integer ID of the last ModelSet that
      #   you’ve seen.
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker model_sets.
      def all_model_sets(options = {})
        paginate "model_sets", options
      end

      # Get a single model_set
      #
      # @param model_set [String] A Looker model_set id.
      # @option options [Hash] look TODO do we need options here?
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.model_set(1)
      def model_set(model_set=nil, options = {})
        get "model_sets/#{model_set}", options
      end

      # Delete a single model_set
      #
      # @param model_set [String] A looker model_set id.
      # @return [Boolean] whether or not the delete succeeded
      # @option options [Hash] look TODO do we need options here?
      # @see look TODO docs link
      # @example
      #   LookerSDK.delete_model_set(1)
      def delete_model_set(model_set=nil, options = {})
        boolean_from_response :delete, "model_sets/#{model_set}", options
      end

      # Update a single model_set.
      #
      # @option model_set [String] id of model_set to update.
      # @param options [Hash] A customizable set of options.
      # @option name [String] name for created model_set
      # @option models [String, Array<String>] list of names of models to
      #   provide access to or string "all" to give access to all models
      # @option options [String] :todo look TODO: Other options for model_set.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.update_model_set(1, {:name => "Marketing", :models => ["business"]})
      def update_model_set(model_set, options = {})
        patch "model_sets/#{model_set}", options
      end

      # Creates a model_set
      #
      # @option options [Hash] A customizable set of options.
      # @option name [String] name for created model_set
      # @option models [String, Array<String>] list of names of models to
      #   provide access to or string "all" to give access to all models
      # @option options [String] :todo look TODO: Other options for model_set.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.create_model_set({:name => "Games", :models => ["zelda", "supersmash"]})
      #   LookerSDK.create_model_set({:name => "every_model", :models => "all"})
      def create_model_set(options = {})
        post 'model_sets', options
      end

      # List all roles associated with a model_set
      #
      # This provides a list of the roles that a model_set has.
      #
      # @param model_set [Integer] ModelSet id.
      # @param options [Hash] Optional options. look TODO do we need options here?
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker Roles associated with a model_set.
      # @example
      #   LookerSDK.roles(1)
      def model_set_roles(model_set, options = {})
        paginate "model_sets/#{model_set}/roles", options
      end
    end

  end
end
