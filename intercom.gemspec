# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "intercom/version"

Gem::Specification.new do |spec|
  spec.name        = "intercom"
  spec.version     = Intercom::VERSION
  spec.authors     = ["Ben McRedmond", "Ciaran Lee", "Darragh Curran", "Jeff Gardner", "Kyle Daigle", "Declan McGrath", "Jamie Osler", "Bob Long"]
  spec.email       = ["ben@intercom.io", "ciaran@intercom.io", "darragh@intercom.io", "jeff@intercom.io", "kyle@digitalworkbox.com", "declan@intercom.io", "jamie@intercom.io", "bob@intercom.io"]
  spec.homepage    = "https://www.intercom.io"
  spec.summary     = %q{Ruby bindings for the Intercom API}
  spec.description = %Q{Intercom (https://www.intercom.io) is a customer relationship management and messaging tool for web app owners. This library wraps the api provided by Intercom. See http://docs.intercom.io/api for more details. }
  spec.license     = "MIT"
  spec.rubyforge_project = "intercom"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'minitest', '~> 5.4'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'mocha', '~> 1.0'
  spec.add_development_dependency "fakeweb", ["~> 1.3"]
  spec.add_development_dependency "pry"

  spec.add_dependency 'json', '~> 1.8'
  spec.required_ruby_version = '>= 2.1.0'
  spec.add_development_dependency 'gem-release'
end
