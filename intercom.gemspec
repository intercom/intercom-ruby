# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "intercom/version"

Gem::Specification.new do |spec|
  spec.name        = "intercom"
  spec.version     = Intercom::VERSION
  spec.authors     = ["Ben McRedmond", "Ciaran Lee", "Darragh Curran",]
  spec.email       = ["ben@intercom.io", "ciaran@intercom.io", "darragh@intercom.io"]
  spec.homepage    = "http://www.intercom.io"
  spec.summary     = %q{Ruby bindings for the Intercom API}
  spec.description = %Q{Intercom (https://www.intercom.io) is a customer relationship management and messaging tool for web app owners. This library wraps the api provided by Intercom. See http://docs.intercom.io/api for more details. }

  spec.rubyforge_project = "intercom"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rest-client"
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'mocha'
end
