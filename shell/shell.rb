require 'rubygems'
require 'bundler/setup'

require 'looker-sdk.rb'
require 'pry'

def sdk
  @sdk ||= LookerSDK::Client.new(
    # Create your own API3 key and add it to a .netrc file in your location of choice.
    :netrc      => true,
    :netrc_file => "./.netrc",

    # Hack to use local looker instance w/o cert
    :connection_options => {:ssl => {:verify => false}},
    :api_endpoint => "https://localhost:19999/api/3.0",

    # Customize to use your specific looker instance
    # :connection_options => {:ssl => {:verify => true}},
    # :api_endpoint => "https://looker.mycoolcompany.com:19999/api/3.0",
  )
end

begin
  puts "Connecting to Looker at '#{sdk.api_endpoint}'"
  puts (code = sdk.alive) == 200 ? "Looker is alive!" : "Sad Looker: #{code}"

  binding.pry self
rescue Exception => e
  puts e
ensure
  puts 'Bye!'
end

