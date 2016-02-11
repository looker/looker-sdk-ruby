require 'sawyer'
require 'ostruct'
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
    # @param &block [Block] Block to be called with |response, chunk| for each chunk of the body from
    #   the server. The block must return true to continue, or false to abort streaming.
    # @return [Sawyer::Resource]
    def get(url, options = {}, &block)
      request :get, url, nil, parse_query_and_convenience_headers(options), &block
    end

    # Make a HTTP POST request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param data [String|Array|Hash] Body and optionally header params for request
    # @param options [Hash] Optional header params for request
    # @param &block [Block] Block to be called with |response, chunk| for each chunk of the body from
    #   the server. The block must return true to continue, or false to abort streaming.
    # @return [Sawyer::Resource]
    def post(url, data = {}, options = {}, &block)
      request :post, url, data, parse_query_and_convenience_headers(options), &block
    end

    # Make a HTTP PUT request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param data [String|Array|Hash] Body and optionally header params for request
    # @param options [Hash] Optional header params for request
    # @param &block [Block] Block to be called with |response, chunk| for each chunk of the body from
    #   the server. The block must return true to continue, or false to abort streaming.
    # @return [Sawyer::Resource]
    def put(url, data = {}, options = {}, &block)
      request :put, url, data, parse_query_and_convenience_headers(options), &block
    end

    # Make a HTTP PATCH request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param data [String|Array|Hash] Body and optionally header params for request
    # @param options [Hash] Optional header params for request
    # @param &block [Block] Block to be called with |response, chunk| for each chunk of the body from
    #   the server. The block must return true to continue, or false to abort streaming.
    # @return [Sawyer::Resource]
    def patch(url, data = {}, options = {}, &block)
      request :patch, url, data, parse_query_and_convenience_headers(options), &block
    end

    # Make a HTTP DELETE request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def delete(url, options = {}, &block)
      request :delete, url, nil, parse_query_and_convenience_headers(options)
    end

    # Make a HTTP HEAD request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def head(url, options = {}, &block)
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

    # Hypermedia agent for the LookerSDK API (with specific options)
    #
    # @return [Sawyer::Agent]
    def make_agent(options = nil)
      options ||= sawyer_options
      Sawyer::Agent.new(api_endpoint, options) do |http|
        http.headers[:accept] = default_media_type
        http.headers[:user_agent] = user_agent
        http.authorization('token', @access_token) if token_authenticated?
      end
    end

    # Cached Hypermedia agent for the LookerSDK API (with default options)
    #
    # @return [Sawyer::Agent]
    def agent
      @agent ||= make_agent
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

    def request(method, path, data, options, &block)
      ensure_logged_in
      return stream_request(method, path, data, options, &block) if block_given?
      @last_response = response = agent.call(method, URI::Parser.new.escape(path.to_s), data, options)
      @raw_responses ? response : response.data
    end

    def stream_request(method, path, data, options, &block)
      conn_opts = faraday_options(:builder => StreamingClient.new(self, &block))
      agent = make_agent(sawyer_options(:faraday => Faraday.new(conn_opts)))
      @last_response = agent.call(method, URI::Parser.new.escape(path.to_s), data, options)
    end

    # Since Faraday currently won't do streaming for us, we use Net::HTTP. Still, we go to the trouble
    # to go through the Sawyer/Faraday codepath so that we can leverage all the header and param
    # processing they do in order to be as consistent as we can with the normal non-streaming codepath.
    # This class replaces the default Faraday 'builder' that Faraday uses to do the actual request after
    # all the setup is done.

    class StreamingClient
      def initialize(client, &block)
        @client, @block = client, block
      end

      # This is the method that faraday calls on a builder to do the actual request and build a response.
      def build_response(connection, request)
        full_path = connection.build_exclusive_url(request.path, request.params,
                                                   request.options.params_encoder).to_s
        http_request = (
          case request.method
          when :get     then Net::HTTP::Get
          when :post    then Net::HTTP::Post
          when :put     then Net::HTTP::Put
          when :patch   then Net::HTTP::Patch
          else raise "Stream to block not supported for '#{request.method}'"
          end
        ).new(full_path, request.headers)

        http_request.body = request.body

        uri = URI(full_path)

        connect_opts = {
          :use_ssl => !!connection.ssl,
          :verify_mode => (connection.ssl.verify rescue true) ?
            OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE,
        }

        response = nil
        Net::HTTP.start(uri.host, uri.port, connect_opts) do |http|
          http.request(http_request) do |resp|
            response = resp
            if response.code == "200"
              response.read_body do |chunk|
                unless @block.call(response, chunk)
                  return OpenStruct.new(status:"0", headers:{}, env:nil, body:nil)
                end
              end
            end
          end
        end

        return OpenStruct.new(status:"500", headers:{}, env:nil, body:nil) unless response

        OpenStruct.new(status:response.code, headers:response, env:nil, body:nil)
      end
    end

    def delete_succeeded?
      !!last_response && last_response.status == 204
    end

    class Serializer < Sawyer::Serializer
      def encode(data)
        data.kind_of?(Faraday::UploadIO) ? data : super
      end
    end

    def serializer
      @serializer ||= (
        require 'json'
        Serializer.new(JSON)
      )
    end

    def faraday_options(options = {})
      conn_opts = @connection_options.clone
      builder = options[:builder] || @middleware
      conn_opts[:builder] = builder if builder
      conn_opts[:proxy] = @proxy if @proxy
      conn_opts
    end

    def sawyer_options(options = {})
      {
        :links_parser => Sawyer::LinkParsers::Simple.new,
        :serializer  => serializer,
        :faraday => options[:faraday] || @faraday || Faraday.new(faraday_options)
      }
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
