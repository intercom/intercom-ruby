source "http://rubygems.org"

gem 'webmock'
gemspec
%w[rspec rspec-core rspec-expectations rspec-mocks rspec-support].each do |lib|
  gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => 'master'
end

group :development, :test do
  platforms :jruby do
    gem 'json-jruby'
    gem 'jruby-openssl'
  end
  platforms :ruby_18 do
    gem 'json_pure'
  end
end
