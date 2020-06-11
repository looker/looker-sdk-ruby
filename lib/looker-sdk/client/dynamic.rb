############################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2018 Looker Data Sciences, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
############################################################################################

module LookerSDK
  class Client

    module Dynamic

      attr_accessor :dynamic

      def try_load_swagger
        resp = get('swagger.json') rescue nil
        resp && last_response && last_response.status == 200 && last_response.data && last_response.data.to_attrs
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
        # First, try to load swagger.json w/o authenticating
        @swagger ||= without_authentication { try_load_swagger }

        unless @swagger
          # try again, this time with authentication
          @swagger = try_load_swagger
        end

        # in unit tests, @swagger may be nil and last_response nil because no HTTP request was made
        if @swagger.nil?
          if @last_error
            raise @last_error
          else
            raise "Load of swagger.json failed."
          end
        end

        @swagger
      end

      def operations
        return @@sharable_operations[api_endpoint] if shared_swagger && @@sharable_operations[api_endpoint]

        if !@swagger && @lazy_swagger
          load_swagger
        end

        return nil unless @swagger
        @operations ||= Hash[
          @swagger[:paths].map do |path_name, path_info|
            path_info.map do |method, route_info|
              route = @swagger[:basePath].to_s + path_name.to_s
              [route_info[:operationId].to_sym, {:route => route, :method => method, :info => route_info}]
            end
          end.reduce(:+)
        ].freeze

        shared_swagger ? (@@sharable_operations[api_endpoint] = @operations) : @operations
      end

      def method_link(entry)
        uri = URI.parse(api_endpoint)
        "#{uri.scheme}://#{uri.host}:#{uri.port}/api-docs/index.html#!/#{entry[:info][:tags].first}/#{entry[:info][:operationId]}" rescue "http://docs.looker.com/"
      end

      # Callers can explicitly 'invoke' remote methods or let 'method_missing' do the trick.
      # If nothing else, this gives clients a way to deal with potential conflicts between remote method
      # names and names of methods on client itself.
      def invoke(method_name, *args, &block)
        entry = find_entry(method_name) || raise(NameError, "undefined remote method '#{method_name}'")
        invoke_remote(entry, method_name, *args, &block)
      end

      def method_missing(method_name, *args, &block)
        entry = find_entry(method_name) || (return super)
        invoke_remote(entry, method_name, *args, &block)
      end

      def respond_to?(method_name, include_private=false)
        !!find_entry(method_name) || super
      end

      private

      def find_entry(method_name)
        operations && operations[method_name.to_sym] if dynamic
      end

      def invoke_remote(entry, method_name, *args, &block)
        args = (args || []).dup
        route = entry[:route].to_s.dup
        params = (entry[:info][:parameters] || []).select {|param| param[:in] == 'path'}
        body_param = (entry[:info][:parameters] || []).select {|param| param[:in] == 'body'}.first

        params_passed = args.length
        params_required = params.length + (body_param && body_param[:required] ? 1 : 0)
        unless params_passed >= params_required
          raise ArgumentError.new("wrong number of arguments (#{params_passed} for #{params_required}) in call to '#{method_name}'. See '#{method_link(entry)}'")
        end

        # substitute the actual params into the route template, encoding if needed
        params.each do |param|
          value = args.shift.to_s
          if value == CGI.unescape(value)
            value = CGI.escape(value)
          end
          route.sub!("{#{param[:name]}}", value)
        end

        a = args.length > 0 ? args[0] : {}
        b = args.length > 1 ? args[1] : {}

        method = entry[:method].to_sym
        case method
        when :get     then get(route, a, true, &block)
        when :post    then post(route, a, merge_content_type_if_body(a, b), true, &block)
        when :put     then put(route, a, merge_content_type_if_body(a, b), true, &block)
        when :patch   then patch(route, a, merge_content_type_if_body(a, b), true, &block)
        when :delete  then delete(route, a, true) ; @raw_responses ? last_response : delete_succeeded?
        else raise "unsupported method '#{method}' in call to '#{method_name}'. See '#{method_link(entry)}'"
        end
      end

    end
  end
end
