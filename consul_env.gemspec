# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'consul_env/version'

Gem::Specification.new do |spec|
  spec.name          = "consul_env"
  spec.version       = ConsulEnv::VERSION
  spec.authors       = ["Mitch Monsen"]
  spec.email         = ["mitch@nav.com"]

  spec.summary       = "Import variables from Consul's K/V store into your local Ruby ENV"
  spec.homepage      = "https://github.com/creditera/consul_env"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.10.3"

  spec.add_runtime_dependency "httparty", "~> 0.13.7"
end
