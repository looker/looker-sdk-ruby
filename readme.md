# [Looker](http://looker.com/) SDK for Ruby

### Development

```bash
$ bundle install
$ rake test # run the test suite
$ rake test:all # run the test suite on all supported Rubies
```

### Installation
```bash
$ rake install
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


# right now very little is supported.
# Basic user getters have been implemented
users = client.all_users

first_user = users[0]

first_user.id          # 1
first_user.first_name  # "Jonathan"
first_user.last_name   # "Swenson"
first_user.models_dir  # "models-user-1"
                       # etc 

user_id = 2
second_user = client.user(user_id)

```