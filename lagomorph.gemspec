# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lagomorph/version'

Gem::Specification.new do |spec|
  spec.name          = "lagomorph"
  spec.version       = Lagomorph::VERSION
  spec.authors       = ["Alessandro Berardi", "Adam Davies"]
  spec.email         = ["berardialessandro@gmail.com", "adzdavies@gmail.com"]
  spec.summary       = %q{RPC Messaging pattern using RabbitMQ}
  spec.description   = %q{
    Lagomorph is a mammal of the order Lagomorpha, which comprises the hares, rabbits, and pikas.

    It's also a gem that implements the RPC pattern over AMPQ using RabbitMQ.
    In this case, it can work with either MRI (through the bunny gem) or jRuby 
    (via the march_hare gem).
  }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # You'll have to include one of these when you use it
  # since gem-build will include one or both...
  #  if RUBY_PLATFORM == 'java' # jruby
  #    spec.add_dependency 'march_hare'
  #  else # mri
  #    spec.add_dependency 'bunny'
  #  end
  spec.add_dependency 'json'

  spec.add_development_dependency "bundler", "~> 1.7"

  # Switch your platform when spec'ing...
  if RUBY_PLATFORM == 'java' # jruby
    spec.add_development_dependency 'march_hare'
  else # mri
    spec.add_development_dependency 'bunny'
  end
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-rcov'
  spec.add_development_dependency 'coveralls'

end
