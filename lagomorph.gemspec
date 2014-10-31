# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lagomorph/version'

Gem::Specification.new do |spec|
  spec.name          = "lagomorph"
  spec.version       = Lagomorph::VERSION
  spec.authors       = ["Alessandro Berardi"]
  spec.email         = ["berardialessandro@gmail.com"]
  spec.summary       = %q{RPC Messaging pattern using RabbitMQ}
  spec.description   = %q{Lagomorph is a mammal of the order Lagomorpha, which comprises the hares, rabbits, and pikas.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'march_hare'
  spec.add_dependency 'json'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
