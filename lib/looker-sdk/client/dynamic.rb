module LookerSDK
  class Client

    module Dynamic

      def load_swagger
        @swagger ||= (
          without_authentication do
            begin
              get 'swagger.json'
            rescue
              # eat any errors
            end
          end
        )
      end

      def operations
        return nil unless @swagger
        @operations ||= (
          ops = {}
          paths = @swagger[:paths].to_h

          paths.each do |path_name, path_info|
            path_info.to_h.each do |method, route_info|
              route_info = route_info.to_h
              ops[route_info[:operationId]] = {:route => path_name, :method => method, :info => route_info }
            end
          end
          ops
        )
      end

      def respond_to?(method_name, include_private=false)
        (operations && !!operations[method_name.to_s]) || super
      end

      def method_link(entry)
        uri = URI.parse(api_endpoint)
        "#{uri.scheme}://#{uri.host}:#{uri.port}/api-docs/index.html#!/#{entry[:info][:tags].first}/#{entry[:info][:operationId]}" rescue "http://docs.looker.com/"
      end

      def method_missing(method_name, *args, &block)
        entry = operations && operations[method_name.to_s]
        return super unless entry

        args = (args || []).dup
        route = entry[:route].to_s
        params = (entry[:info][:parameters] || []).select {|param| param[:in] == 'path'}
        body_param = (entry[:info][:parameters] || []).select {|param| param[:in] == 'body'}.first

        params_passed = args.length
        params_required = params.length + (body_param && body_param[:required] ? 1 : 0)
        raise ArgumentError.new("wrong number of arguments (#{params_passed} for #{params_required}) in call to '#{method_name}'. See '#{method_link(entry)}'") unless params_passed >= params_required

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
