# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "intercom/version"

Gem::Specification.new do |s|
  s.name        = "intercom"
  s.version     = Intercom::VERSION
  s.authors     = ["Darragh Curran"]
  s.email       = ["darragh@peelmeagrape.net"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "intercom"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_runtime_dependency "rest-client"
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
end
