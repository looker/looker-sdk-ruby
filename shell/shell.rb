require 'rubygems'
require 'bundler/setup'

require 'looker-sdk.rb'
require 'pry'

def sdk
  @sdk ||= LookerSDK::Client.new(
    # Create your own API3 key and add it to a .netrc file in your location of choice.
    :netrc      => true,
    :netrc_file => "./.netrc",

    # Disable cert verification if the looker has a self-signed cert.
    # :connection_options => {:ssl => {:verify => false}},

    # Support self-signed cert *and* set longer timeout to allow for long running queries.
    :connection_options => {:ssl => {:verify => false}, :request => {:timeout => 60 * 60, :open_timeout => 30}},

    :api_endpoint => "https://localhost:19999/api/3.0",

    # Customize to use your specific looker instance
    # :connection_options => {:ssl => {:verify => true}},
    # :api_endpoint => "https://looker.mycoolcompany.com:19999/api/3.0",
  )
end

begin
  puts "Connecting to Looker at '#{sdk.api_endpoint}'"
  puts sdk.alive? ? "Looker is alive!" : "Sad Looker, can't connect:\n  #{sdk.last_error}"
  puts sdk.authenticated? ? "Authenticated!" : "Sad Looker, can't authenticate:\n  #{sdk.last_error}"

  binding.pry self
rescue Exception => e
  puts e
ensure
  puts 'Bye!'
end

