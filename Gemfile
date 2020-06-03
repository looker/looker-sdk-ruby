source 'https://rubygems.org'

group :development do
  gem 'awesome_print', '~>1.6.1', :require => 'ap'
  gem 'redcarpet', '~>3.1.2', :platforms => :ruby
end

group :development, :test do
  gem 'rake', '< 11.0'
end

group :test do
  # gem 'json', '~> 1.7', :platforms => [:jruby] look TODO needed?
  gem 'minitest',         '5.9.1'
  gem 'mocha',            '1.1.0'
  gem 'rack',             '1.6.4'
  gem 'rack-test',        '0.6.2'
  gem 'netrc', '~> 0.7.7'
  gem 'simplecov', '~> 0.7.1', :require => false
end

gemspec
