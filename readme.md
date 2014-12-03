# [Looker](http://looker.com/) SDK for Ruby

### Installation
```bash
$ git clone git@github.com:looker/looker-sdk-ruby.git looker-sdk
$ cd looker-sdk
$ bundle install
$ rake install
```

### Development

```bash
$ bundle install
$ rake test # run the test suite
$ rake test:all # run the test suite on all supported Rubies
```

### TODO
Things that we think are important to do will be marked with `look TODO`


### Basic Usage

```ruby
require 'looker-sdk'

client = LookerSDK::Client.new(
  :client_id => "4CN7jzm7yrkcy2MC4CCG",
  :client_secret => "Js3rZZ7vHfbc2hBynSj7zqKh"
  :api_endpoint => "https://mygreatcompany.looker.com:19999/api/3.0"
)

# if you don't want to provide credentials: (trust me you don't)
# add the following to your ~/.netrc file (or create the file if you don't have one):
# machine localhost
#   login nope
#   password nopepass
client = LookerSDK::Client.new(
  :netrc      => true,
  :netrc_file => "~/.net_rc"
)


# Supports user creation, modification, deletion
# Supports credentials_user creation, modification, and deletion.
first_user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
LookerSDK.create_credentials_email(first_user[:id], "jonathan@looker.com")
second_user = LookerSDK.create_user({:first_name => "John F", :last_name => "Kennedy"})
LookerSDK.create_credentials_email(first_user[:id], "john@looker.com")
third_user = LookerSDK.create_user({:first_name => "Frank", :last_name => "Sinatra"})
LookerSDK.create_credentials_email(first_user[:id], "frank@looker.com")

user = LookerSDK.user(first_user[:id])
user.first_name # Jonathan
user.last_name  # Swenson

LookerSDK.update_user(first_user[:id], {:first_name => "Jonathan is awesome"}
user = LookerSDK.user(first_user[:id])
user.first_name # "Jonathan is awesome"

credentials_email = LookerSDK.get_credentials_email(user[:id])
credentials_email[:email] # jonathan@looker.com
LookerSDK.update_credentials_email(user[:id], {:email => "jonathan+1@looker.com"})
credentials_email = LookerSDK.get_credentials_email(user[:id])
credentials_email[:email] # jonathan+1@looker.com

users = LookerSDK.all_users()
users.length # 3
users[0]     # first_user


LookerSDK.delete_credentials_email(second_user[:id])
LookerSDK.delete_user(second_user[:id])

users = LookerSDK.all_user()
users.length # 2
users[1]     # third_user

```
