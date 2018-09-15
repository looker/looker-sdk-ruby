############################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2015 Looker Data Sciences, Inc.
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
