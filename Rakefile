require "bundler/gem_tasks"
require 'rake/testtask'
require 'rake/clean'

Rake::TestTask.new("spec:unit") do |spec|
  spec.libs.push "lib"
  spec.libs.push "spec/unit"
  spec.test_files = FileList['spec/unit/**/*_spec.rb']
  spec.warning = true
end

Rake::TestTask.new("spec:integration") do |spec|
  spec.libs.push "lib"
  spec.test_files = FileList['spec/integration/**/*_spec.rb']
  spec.warning = true
end

task :spec => "spec:unit"

require 'rdoc/task'
RDoc::Task.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

task :default => :spec