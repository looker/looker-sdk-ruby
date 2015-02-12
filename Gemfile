source 'https://rubygems.org'

gem 'jruby-openssl', :platforms => :jruby
gem 'sawyer', '~> 0.6'

group :development do
  gem 'awesome_print', :require => 'ap'
  gem 'yard', '~> 0.8.7'
  gem 'redcarpet', '~> 3.1.2', :platforms => :ruby
  gem 'rake', :platforms => :jruby
end

group :test do
  # gem 'json', '~> 1.7', :platforms => [:jruby] look TODO needed?
  gem 'minitest'
  gem 'netrc', '~> 0.7.7'
  gem 'simplecov', '~> 0.7.1', :require => false
end

gemspec
