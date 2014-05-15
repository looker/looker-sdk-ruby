# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'looker/version'

Gem::Specification.new do |s|
  s.name        = 'looker-sdk'
  s.version     = Looker::VERSION
  s.authors     = ['Looker'] # look TODO is this the right author?
  # s.email       = 'eng@looker.com' look TODO where should folks email about our open source stuff?
  s.homepage    = 'https://github.com/looker/looker-sdk-ruby' # look TODO is this the right url?
  s.summary     = %q{Looker Ruby SDK}
  s.description = %q{Looker Ruby SDK}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)
end
