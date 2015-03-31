module LookerSDK
  class Client

    module Dynamic

      def try_load_swagger
        body = get('swagger.json') rescue nil
        last_response && last_response.status == 200 && body
      end

      # If a given client is created with ':shared_swagger => true' then it will try to
      # use a globally sharable @@operations hash built from one fetch of the swagger.json for the
      # given api_endpoint. This is an optimization for the cases where many sdk clients get created and
      # destroyed (perhaps with different access tokens) while all talking to the same endpoints. This cuts
      # down overhead for such cases considerably.

      @@sharable_operations = Hash.new

      def clear_swagger
        @swagger = @operations = nil
      end

      def load_swagger
        # We only need the swagger if we are going to be building our own 'operations' hash
        return if shared_swagger && @@sharable_operations[api_endpoint]
        # Try to load w/o authenticating. Else, authenticate and try again.
        @swagger ||= without_authentication {try_load_swagger} || try_load_swagger
      end

      def operations
        return @@sharable_operations[api_endpoint] if shared_swagger && @@sharable_operations[api_endpoint]

        return nil unless @swagger
        @operations ||= Hash[
          @swagger[:paths].to_h.map do |path_name, path_info|
            path_info.to_h.map do |method, route_info|
              route = @swagger[:basePath].to_s + path_name.to_s
              [route_info[:operationId], {:route => route, :method => method, :info => route_info.to_h}]
            end
          end.reduce(:+)
        ].freeze

        shared_swagger ? (@@sharable_operations[api_endpoint] = @operations) : @operations
      end

      def method_link(entry)
        uri = URI.parse(api_endpoint)
        "#{uri.scheme}://#{uri.host}:#{uri.port}/api-docs/index.html#!/#{entry[:info][:tags].first}/#{entry[:info][:operationId]}" rescue "http://docs.looker.com/"
      end

      def respond_to?(method_name, include_private=false)
        (operations && !!operations[method_name.to_s]) || super
      end

      attr_accessor :dynamic

      def method_missing(method_name, *args, &block)
        entry = operations && operations[method_name.to_s] if dynamic
        return super unless entry

        args = (args || []).dup
        route = entry[:route].to_s.dup
        params = (entry[:info][:parameters] || []).select {|param| param[:in] == 'path'}
        body_param = (entry[:info][:parameters] || []).select {|param| param[:in] == 'body'}.first

        params_passed = args.length
        params_required = params.length + (body_param && body_param[:required] ? 1 : 0)
        unless params_passed >= params_required
          raise ArgumentError.new("wrong number of arguments (#{params_passed} for #{params_required}) in call to '#{method_name}'. See '#{method_link(entry)}'")
        end

        # substitute the actual params into the route template
        params.each {|param| route.sub!("{#{param[:name]}}", args.shift.to_s) }

        opts = args[0] || {}

        method = entry[:method].to_sym
        case method
        when :get     then paginate(route, opts)
        when :post    then post(route, opts)
        when :put     then put(route, opts)
        when :patch   then patch(route, opts)
        when :delete  then boolean_from_response(:delete, route, opts)
        else raise "unsupported method '#{method}' in call to '#{method_name}'. See '#{method_link(entry)}'"
        end
      end
    end
  end
end
