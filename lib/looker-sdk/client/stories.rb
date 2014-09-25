module LookerSDK
  class Client

    # Methods for the Stories API
    module Stories

      # List all Looker stories
      #
      # This provides a dump of every story, in the order that they signed up
      # for Looker.
      #
      # @param options [Hash] Optional options. look TODO do we need options here?
      # @option options [Integer] :since The integer ID of the last RoleType that
      #   you’ve seen.
      #
      # @see look TODO docs link
      #
      # @return [Array<Sawyer::Resource>] List of Looker stories.
      def all_stories(options = {})
        paginate "stories", options
      end

      # Get a single story
      #
      # @param story [String] A Looker story id.
      # @return [Sawyer::Resource]
      # @see look TODO docs link
      # @example
      #   LookerSDK.story(1)
      def story(story = nil, options = {})
        get "stories/#{story}", options
      end

    end

  end
end
