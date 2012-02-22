# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "intercom/version"

Gem::Specification.new do |s|
  s.name        = "intercom"
  s.version     = Intercom::VERSION
  s.authors     = ["Ben McRedmond", "Ciaran Lee", "Darragh Curran",]
  s.email       = ["ben@intercom.io", "ciaran@intercom.io", "darragh@intercom.io"]
  s.homepage    = "http://intercom.io"
  s.summary     = %q{Ruby bindings for the Intercom API}
  s.description = %q{Intercom is a customer relationship management and messaging tool for web app owners. See http://intercom.io for more details.}

  s.rubyforge_project = "intercom"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rest-client"
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'mocha'
end
