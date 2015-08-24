# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth-yahoo/version"

Gem::Specification.new do |s|
  s.name        = "omniauth-yahoo"
  s.version     = Omniauth::Yahoo::VERSION
  s.authors     = ["Tim Breitkreutz"]
  s.email       = ["tim@sbrew.com"]
  s.homepage    = "https://github.com/timbreitkreutz/omniauth-yahoo"
  s.summary     = %q{OmniAuth strategy for yahoo}
  s.description = %q{OmniAuth strategy for yahoo}

  s.rubyforge_project = "omniauth-yahoo"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'omniauth-oauth', '~> 1.0'

  s.license = 'MIT'
end
