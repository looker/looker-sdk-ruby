###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

# Make Sawyer decode the body lazily.
# This is a temp monkey-patch until sawyer has: https://github.com/lostisland/sawyer/pull/31
# At that point we can remove this and update our dependency to the new Sawyer release version.

module Sawyer
  class Response

    attr_reader :env, :body

    def initialize(agent, res, options = {})
      @agent   = agent
      @status  = res.status
      @headers = res.headers
      @env     = res.env
      @body    = res.body
      @rels    = process_rels
      @started = options[:sawyer_started]
      @ended   = options[:sawyer_ended]
    end

    def data
      @data ||= begin
        return(body) unless (headers[:content_type] =~ /json|msgpack/)
        process_data(agent.decode_body(body))
      end
    end

    def inspect
      %(#<#{self.class}: #{@status} @rels=#{@rels.inspect} @data=#{data.inspect}>)
    end

  end
end
