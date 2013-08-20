# -*- encoding: utf-8 -*-
require File.expand_path('../lib/lycopodium/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "lycopodium"
  s.version     = Lycopodium::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Open North"]
  s.email       = ["info@opennorth.ca"]
  s.homepage    = "http://github.com/opennorth/lycopodium"
  s.summary     = %q{Test what transformations you can make to a set of unique strings without creating collisions}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('rspec', '~> 2.10')
  s.add_development_dependency('rake')
end
