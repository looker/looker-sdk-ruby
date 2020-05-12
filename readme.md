# [Looker](http://looker.com/) SDK for Ruby [![Build Status](https://travis-ci.org/looker/looker-sdk-ruby.svg)](https://travis-ci.org/looker/looker-sdk-ruby)
### Overview
This SDK supports secure/authenticated access to the Looker RESTful API. The SDK binds dynamically to the Looker API and builds mappings for the sets of API methods that the Looker instance exposes. This allows for writing straightforward Ruby scripts to interact with the Looker API. And, it allows the SDK to provide access to new Looker API features in each Looker release without requiring an update to the SDK each time.

The Looker API uses OAuth2 authentication. 'API3' keys can be generated by Looker admins for any Looker user account from the Looker admin panel. These 'keys' each consist of a client_id/client_secret pair. These keys should be carefully protected as one would with any critical password. When using the SDK, one creates a client object that is initialized with a client_id/client_secret pair and the base URL of the Looker instance's API endpoint. The SDK transparently logs in to the API with that key pair to generate a short-term auth token that it sends to the API with each subsequent call to provide authentication for that call.

All calls to the Looker API must be done over a TLS/SSL connection. Requests and responses are then encrypted at that transport layer. It is highly recommended that Looker instance https endpoints use certificates that are properly signed by a trusted certificate authority. The SDK will, by default, validate server certificates. It is possible to disable that validation when creating an SDK client object if necessary. But, that configuration is discouraged.

Looker instances expose API documentation at: https://mygreatcompany.looker.com:19999/api-docs/index.html (the exact URL can be set in the Looker admin panel). By default, the documentation page requires a client_id/client_secret pair to load the detailed API information. That page also supports "Try it out!" links so that you can experiment with the API right from the documentation. The documentation is intended to show how to call the API endpoints via either raw RESTful https requests or using the SDK.

Keep in mind that all API calls are done 'as' the user whose credentials were used to login to the API. The Looker permissioning system enforces various rules about which activities users with various permissions are and are not allowed to do; and data they are or are not allowed to access. For instance, there are many configuration and looker management activities that only Admin users are allowed to perform; like creating and asigning user roles. Additionally, non-admin users have very limited access to information about other users.

When trying to access a resource with the API that the current user is not allowed to access, the API will return a '404 Not Found' error - the same as if the resource did not exist at all. This is a standard practice for RESTful services. By default, the Ruby SDK will convert all non-success result codes into ruby exceptions which it then raises. So, error paths are handled by rescuing exceptions rather than checking result codes for each SDK request.

### Installation
```bash
$ git clone git@github.com:looker/looker-sdk-ruby.git looker-sdk
$ cd looker-sdk
$ gem install bundle
$ bundle install
$ rake install
```

### Development

```bash
$ bundle install
$ rake test # run the test suite
$ make install test # run the test suite on all supported Rubies
```

### Basic Usage

```ruby
require 'looker-sdk'

# An sdk client can be created with an explicit client_id/client_secret pair
# (this is discouraged because secrets in code files can easily lead to those secrets being compromised!)
sdk = LookerSDK::Client.new(
  :client_id => "4CN7jzm7yrkcy2MC4CCG",
  :client_secret => "Js3rZZ7vHfbc2hBynSj7zqKh",
  :api_endpoint => "https://mygreatcompany.looker.com:19999/api/3.0"
)

# If you don't want to provide explicit credentials: (trust me you don't)
# add the below to your ~/.netrc file (or create the file if you don't have one).
# Note that to use netrc you need to install the netrc ruby gem.
#
# machine mygreatcompany.looker.com
#   login my_client_id
#   password my_client_secret

sdk = LookerSDK::Client.new(
  :netrc      => true,
  :netrc_file => "~/.net_rc",
  :api_endpoint => "https://mygreatcompany.looker.com:19999/api/3.0",

  # Set longer timeout to allow for long running queries. The default is 60 seconds and can be problematic.
  :connection_options => {:request => {:timeout => 60 * 60, :open_timeout => 30}},

  # Alternately, disable cert verification if the looker has a self-signed cert.
  # Avoid this if using real certificates; verification of the server cert is a very good thing for production.
  # :connection_options => {:ssl => {:verify => false}},

  # Alternately, support self-signed cert *and* set longer timeout to allow for long running queries.
  # :connection_options => {:ssl => {:verify => false}, :request => {:timeout => 60 * 60, :open_timeout => 30}},
)

# Check if we can even communicate with the Looker - without even trying to authenticate.
# This will throw an exception if the sdk can't connect at all. This can help a lot with debugging your
# first attempts at using the sdk.
sdk.alive

# Supports user creation, modification, deletion
# Supports email_credentials creation, modification, and deletion.

first_user = sdk.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
sdk.create_user_credentials_email(first_user[:id], {:email => "jonathan@example.com"})

second_user = sdk.create_user({:first_name => "John F", :last_name => "Kennedy"})
sdk.create_user_credentials_email(second_user[:id], {:email => "john@example.com"})

third_user = sdk.create_user({:first_name => "Frank", :last_name => "Sinatra"})
sdk.create_user_credentials_email(third_user[:id], {:email => "frank@example.com"})

user = sdk.user(first_user[:id])
user.first_name # Jonathan
user.last_name  # Swenson

sdk.update_user(first_user[:id], {:first_name => "Jonathan is awesome"})
user = sdk.user(first_user[:id])
user.first_name # "Jonathan is awesome"

credentials_email = sdk.user_credentials_email(user[:id])
credentials_email[:email] # jonathan@example.com

sdk.update_user_credentials_email(user[:id], {:email => "jonathan+1@example.com"})
credentials_email = sdk.user_credentials_email(user[:id])
credentials_email[:email] # jonathan+1@example.com

users = sdk.all_users()
users.length # 3
users[0]     # first_user


sdk.delete_user_credentials_email(second_user[:id])
sdk.delete_user(second_user[:id])

users = sdk.all_users()
users.length # 2
users[1]     # third_user

```

### TODO
Things that we think are important to do will be marked with `look TODO`

