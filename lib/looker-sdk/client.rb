require 'sawyer'
require 'looker-sdk/sawyer_patch'
require 'looker-sdk/configurable'
require 'looker-sdk/authentication'
require 'looker-sdk/rate_limit'
require 'looker-sdk/client/dynamic'

module LookerSDK

  # Client for the LookerSDK API
  #
  # @see look TODO docs link
  class Client

    include LookerSDK::Authentication
    include LookerSDK::Configurable
    include LookerSDK::Client::Dynamic

    # Header keys that can be passed in options hash to {#get},{#head}
    CONVENIENCE_HEADERS = Set.new([:accept, :content_type])

    def initialize(opts = {})
      # Use options passed in, but fall back to module defaults
      LookerSDK::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", opts[key] || LookerSDK.instance_variable_get(:"@#{key}"))
      end

      # allow caller to do configuration in a block before we load swagger and become dynamic
      yield self if block_given?

      # Save the original state of the options because live variables received later like access_token and
      # client_id appear as if they are options and confuse the automatic client generation in LookerSDK#client
      @original_options = options.dup

      load_credentials_from_netrc unless application_credentials?
      load_swagger
      self.dynamic = true
    end

    # Compares client options to a Hash of requested options
    #
    # @param opts [Hash] Options to compare with current client options
    # @return [Boolean]
    def same_options?(opts)
      opts.hash == @original_options.hash
    end

    # Text representation of the client, masking tokens and passwords
    #
    # @return [String]
    def inspect
      inspected = super

      # Only show last 4 of token, secret
      [@access_token, @client_secret].compact.each do |str|
        len = [str.size - 4, 0].max
        inspected = inspected.gsub! str, "#{'*'*len}#{str[len..-1]}"
      end

      inspected
    end

    # Make a HTTP GET request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def get(url, options = {})
      request :get, url, nil, parse_query_and_convenience_headers(options)
    end

    # Make a HTTP POST request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param data [String|Array|Hash] Body and optionally header params for request
    # @param options [Hash] Optional header params for request
    # @return [Sawyer::Resource]
    def post(url, data = {}, options = {})
      request :post, url, data, parse_query_and_convenience_headers(options)
    end

    # Make a HTTP PUT request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param data [String|Array|Hash] Body and optionally header params for request
    # @param options [Hash] Optional header params for request
    # @return [Sawyer::Resource]
    def put(url, data = {}, options = {})
      request :put, url, data, parse_query_and_convenience_headers(options)
    end

    # Make a HTTP PATCH request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param data [String|Array|Hash] Body and optionally header params for request
    # @param options [Hash] Optional header params for request
    # @return [Sawyer::Resource]
    def patch(url, data = {}, options = {})
      request :patch, url, data, parse_query_and_convenience_headers(options)
    end

    # Make a HTTP DELETE request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def delete(url, options = {})
      request :delete, url, nil, parse_query_and_convenience_headers(options)
    end

    # Make a HTTP HEAD request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def head(url, options = {})
      request :head, url, nil, parse_query_and_convenience_headers(options)
    end

    # Make one or more HTTP GET requests, optionally fetching
    # the next page of results from URL in Link response header based
    # on value in {#auto_paginate}.
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @param block [Block] Block to perform the data concatination of the
    #   multiple requests. The block is called with two parameters, the first
    #   contains the contents of the requests so far and the second parameter
    #   contains the latest response.
    # @return [Sawyer::Resource]
    def paginate(url, options = {}, &block)
      opts = parse_query_and_convenience_headers(options)
      if @auto_paginate || @per_page
        opts[:query][:per_page] ||=  @per_page || (@auto_paginate ? 100 : nil)
      end

      data = request(:get, url, nil, opts)

      if @auto_paginate
        while @last_response.rels[:next] && rate_limit.remaining > 0
          @last_response = @last_response.rels[:next].get
          if block_given?
            yield(data, @last_response)
          else
            data.concat(@last_response.data) if @last_response.data.is_a?(Array)
          end
        end

      end

      data
    end

    # Hypermedia agent for the LookerSDK API
    #
    # @return [Sawyer::Agent]
    def agent
      @agent ||= Sawyer::Agent.new(api_endpoint, sawyer_options) do |http|
        http.headers[:accept] = default_media_type
        http.headers[:user_agent] = user_agent
        http.authorization('token', @access_token) if token_authenticated?
      end
    end

    # Fetch the root resource for the API
    #
    # @return [Sawyer::Resource]
    def root
      get URI(api_endpoint).path.sub(/\/$/,'')
    end

    # Is the server alive (this can be called w/o authentication)
    #
    # @return http status code
    def alive
      get '/alive'
      last_response.status
    end

    # Response for last HTTP request
    #
    # @return [Sawyer::Response]
    def last_response
      @last_response if defined? @last_response
    end

    # Set OAuth access token for authentication
    #
    # @param value [String] Looker OAuth access token
    def access_token=(value)
      reset_agent
      @access_token = value
    end

    # Set OAuth app client_id
    #
    # @param value [String] Looker OAuth app client_id
    def client_id=(value)
      reset_agent
      @client_id = value
    end

    # Set OAuth app client_secret
    #
    # @param value [String] Looker OAuth app client_secret
    def client_secret=(value)
      reset_agent
      @client_secret = value
    end

    # Wrapper around Kernel#warn to print warnings unless
    # LOOKER_SILENT is set to true.
    #
    # @return [nil]
    def looker_warn(*message)
      unless ENV['LOOKER_SILENT']
        warn message
      end
    end

    private

    def reset_agent
      @agent = nil
    end

    def request(method, path, data, options)
      ensure_logged_in
      @last_response = response = agent.call(method, URI::Parser.new.escape(path.to_s), data, options)
      @raw_responses ? response : response.data
    end

    def delete_succeeded?
      !!last_response && last_response.status == 204
    end

    class Serializer < Sawyer::Serializer
      def encode(data)
        data.kind_of?(Faraday::UploadIO) ? data : super
      end

      # slight modification to the base class' decode_has_value function to
      # less permissive when decoding time values.
      #
      # See https://github.com/looker/helltool/issues/22037 for more details
      def decode_hash_value(key, value)
        if time_field?(key, value)
          if value.is_a?(String)
            begin
              Time.iso8601(value)
            rescue ArgumentError
              value
            end
          elsif value.is_a?(Integer) || value.is_a?(Float)
            Time.at(value)
          else
            value
          end
        elsif value.is_a?(Hash)
          decode_hash(value)
        elsif value.is_a?(Array)
          value.map { |o| decode_hash_value(key, o) }
        else
          value
        end
      end
    end

    def serializer
      @serializer ||= (
        require 'json'
        Serializer.new(JSON)
      )
    end

    def sawyer_options
      opts = {
        :links_parser => Sawyer::LinkParsers::Simple.new
      }
      conn_opts = @connection_options
      conn_opts[:builder] = @middleware if @middleware
      conn_opts[:proxy] = @proxy if @proxy
      opts[:serializer] = serializer
      opts[:faraday] = @faraday || Faraday.new(conn_opts)

      opts
    end

    def merge_content_type_if_body(body, options = {})
      if body
        if body.kind_of?(Faraday::UploadIO)
          length = File.new(body.local_path).size.to_s
          headers = {:content_type => body.content_type, :content_length => length}.merge(options[:headers] || {})
        else
          headers = {:content_type => default_media_type}.merge(options[:headers] || {})
        end
        {:headers => headers}.merge(options)
      else
        options
      end
    end

    def parse_query_and_convenience_headers(options)
      return {} if options.nil?
      raise "options is not a hash" unless options.is_a?(Hash)
      return {} if options.empty?

      options = options.dup
      headers = options.delete(:headers) || {}
      CONVENIENCE_HEADERS.each do |h|
        if header = options.delete(h)
          headers[h] = header
        end
      end
      query = options.delete(:query) || {}
      raise "query '#{query}' is not a hash" unless query.is_a?(Hash)
      query = options.merge(query)

      opts = {}
      opts[:query] = query unless query.empty?
      opts[:headers] = headers unless headers.empty?

      opts
    end
  end
end
