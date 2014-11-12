module LookerSDK
  class Client

    # Methods for the Stories API
    module Stories

      # List all Looker stories
      #
      # This provides a listing of of every story.
      #
      # @return [Array<Sawyer::Resource>] List of Looker stories.
      def all_stories
        paginate "stories"
      end

      # Get a single story
      #
      # @param story [String] A Looker story id.
      # @return [Sawyer::Resource]
      # @example
      #   LookerSDK.story(1)
      def story(story)
        get "stories/#{story}"
      end

      # Get story assets
      #
      # @return [Sawyer::Resource]
      # @example
      #   LookerSDK.story_assets
      def story_assets
        get "stories/assets"
      end

    end

  end
end
