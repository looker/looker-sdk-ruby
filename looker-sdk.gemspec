# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'looker-sdk/version'

Gem::Specification.new do |s|
  s.name        = 'looker-sdk'
  s.version     = LookerSDK::VERSION
  s.date        = "#{Time.now.strftime('%F')}"
  s.authors     = ['Looker']
  s.email       = 'support@looker.com'
  s.homepage    = 'https://github.com/looker/looker-sdk-ruby'
  s.summary     = %q{Looker Ruby SDK}
  s.description = 'Use this SDK to access data and configuration of your Looker instance. ' +
      'With the Looker API you can automate administrative tasks such as provisioning users, ' +
      'configuring db connections, and so on. The Looker API also enables you to leverage the Looker ' +
      'data analytics engine to fetch data or render visualizations defined in your Looker data models. ' +
      'For more information, see https://looker.com'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 1.9.3'
  s.requirements = 'Looker version 4.0 or later'  # informational

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)
  s.add_dependency 'jruby-openssl' if s.platform == :jruby
  s.add_dependency 'sawyer', '0.6'
end
