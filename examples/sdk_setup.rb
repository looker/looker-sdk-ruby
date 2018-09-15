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

require 'rubygems'
require 'bundler/setup'

require 'looker-sdk'

# common file used by various examples to setup and init sdk

def sdk
  @sdk ||= LookerSDK::Client.new(
    :netrc      => true,
    :netrc_file => "./.netrc",

    # use my local looker with self-signed cert
    :connection_options => {:ssl => {:verify => false}},
    :api_endpoint => "https://localhost:19999/api/3.0",

    # use a real looker the way you are supposed to!
    # :connection_options => {:ssl => {:verify => true}},
    # :api_endpoint => "https://mycoolcompany.looker.com:19999/api/3.0",
  )
end
