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

module LookerSDK

  # Class for API Rate Limit info
  #
  # @!attribute [w] limit
  #   @return [Fixnum] Max tries per rate limit period
  # @!attribute [w] remaining
  #   @return [Fixnum] Remaining tries per rate limit period
  # @!attribute [w] resets_at
  #   @return [Time] Indicates when rate limit resets
  # @!attribute [w] resets_in
  #   @return [Fixnum] Number of seconds when rate limit resets
  #
  # @see look TODO docs link
  class RateLimit < Struct.new(:limit, :remaining, :resets_at, :resets_in)

    # Get rate limit info from HTTP response
    #
    # @param response [#headers] HTTP response
    # @return [RateLimit]
    def self.from_response(response)
      info = new
      if response && !response.headers.nil?
        info.limit = (response.headers['X-RateLimit-Limit'] || 1).to_i
        info.remaining = (response.headers['X-RateLimit-Remaining'] || 1).to_i
        info.resets_at = Time.at((response.headers['X-RateLimit-Reset'] || Time.now).to_i)
        info.resets_in = (info.resets_at - Time.now).to_i
      end

      info
    end
  end
end
