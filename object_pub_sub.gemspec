# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'object_pub_sub/version'

Gem::Specification.new do |gem|
  gem.name          = "object_pub_sub"
  gem.version       = ObjectPubSub::VERSION
  gem.authors       = ["John Wilger"]
  gem.email         = ["johnwilger@gmail.com"]
  gem.description   = %q{An Observer implementation with finer-grained controll over event publishing.}
  gem.summary       = %q{An Observer implementation with finer-grained controll over event publishing.}
  gem.homepage      = "http://github.com/jwilger/object_pub_sub"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport', '>= 3.0.0'
  gem.add_development_dependency 'rspec'
end
