require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:spec) do |spec|
  spec.libs.push "lib"
  spec.libs.push "spec"
  spec.test_files = FileList['spec/**/*_spec.rb']
  spec.warning = true
end

task :default => :spec