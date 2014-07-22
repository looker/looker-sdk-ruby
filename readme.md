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

### Basic Usage

```ruby
require 'looker-sdk'

# For the time being, log in using dummy credentials.
client = Looker::Client.new(
  :login => "nope",
  :password => "nopepass"
)

# if you don't want to provide credentials: (trust me you don't)
# add the following to your ~/.netrc file (or create the file if you don't have one):
# machine localhost
#   login nope
#   password nopepass
client = Looker::Client.new(
  :netrc      => true,
  :netrc_file => "~/.net_rc"
)


# Supports user creation, modification, deletion
# Supports credentials_user creation, modification, and deletion.
first_user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
Looker.create_credentials_email(first_user[:id], "jonathan@looker.com")
second_user = Looker.create_user({:first_name => "John F", :last_name => "Kennedy"})
Looker.create_credentials_email(first_user[:id], "john@looker.com")
third_user = Looker.create_user({:first_name => "Frank", :last_name => "Sinatra"})
Looker.create_credentials_email(first_user[:id], "frank@looker.com")

user = Looker.user(first_user[:id])
user.first_name # Jonathan
user.last_name  # Swenson

Looker.update_user(first_user[:id], {:first_name => "Jonathan is awesome"}
user = Looker.user(first_user[:id])
user.first_name # "Jonathan is awesome"

credentials_email = Looker.get_credentials_email(user[:id])
credentials_email[:email] # jonathan@looker.com
Looker.update_credentials_email(user[:id], {:email => "jonathan+1@looker.com"})
credentials_email = Looker.get_credentials_email(user[:id])
credentials_email[:email] # jonathan+1@looker.com

users = Looker.all_users()
users.length # 3
users[0]     # first_user


Looker.delete_credentials_email(second_user[:id])
Looker.delete_user(second_user[:id])

users = Looker.all_user()
users.length # 2
users[1]     # third_user

```
