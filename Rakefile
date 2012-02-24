require "bundler/gem_tasks"
require 'rake/testtask'
require 'rake/clean'

Rake::TestTask.new(:spec) do |spec|
  spec.libs.push "lib"
  spec.libs.push "spec"
  spec.test_files = FileList['spec/**/*_spec.rb']
  spec.warning = true
end

require 'rdoc/task'
RDoc::Task.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

task :default => :spec