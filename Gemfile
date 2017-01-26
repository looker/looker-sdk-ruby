source 'https://rubygems.org'

group :development do
  gem 'awesome_print', :require => 'ap'
  gem 'yard', '~> 0.8.7'
  gem 'redcarpet', '~> 3.1.2', :platforms => :ruby
end

group :development, :test do
  gem 'rake', '< 11.0'
end

group :test do
  # gem 'json', '~> 1.7', :platforms => [:jruby] look TODO needed?
  gem 'minitest',         '5.3.5'
  gem 'mocha',            '1.1.0'
  gem 'rack',             '1.6.0'
  gem 'rack-test',        '0.6.2'
  gem 'netrc', '~> 0.7.7'
  gem 'simplecov', '~> 0.7.1', :require => false
end

gemspec
