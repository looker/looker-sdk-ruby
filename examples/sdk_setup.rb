require 'rubygems'
require 'bundler/setup'

require 'looker-sdk'

# common file used by vatious examples to setup and init sdk

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
