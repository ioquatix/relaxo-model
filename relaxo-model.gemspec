# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relaxo/model/version'

Gem::Specification.new do |spec|
	spec.name          = "relaxo-model"
	spec.version       = Relaxo::Model::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	spec.description   = <<-EOF
		Relaxo Model provides a framework for business logic on top of
		Relaxo/CouchDB. While it supports some traditional ORM style patterns, it is
		primary focus is to model business processes and logic.
	EOF
	spec.summary       = "A model layer for CouchDB with minimal global state."
	spec.homepage      = "http://www.codeotaku.com/projects/relaxo/model"
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]
	
	spec.add_dependency("relaxo", "~> 0.6")
	spec.add_dependency("msgpack", "~> 1.0")
	
	spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rspec", "~> 3.4.0"
	spec.add_development_dependency "rake"
end
