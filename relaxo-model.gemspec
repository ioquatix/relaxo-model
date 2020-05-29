
require_relative "lib/relaxo/model/version"

Gem::Specification.new do |spec|
	spec.name = "relaxo-model"
	spec.version = Relaxo::Model::VERSION
	
	spec.summary = "A model layer for the relaxo document database."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "http://www.codeotaku.com/projects/relaxo/model"
	
	spec.files = Dir.glob('{lib,spec}/**/*', File::FNM_DOTMATCH, base: __dir__)

	spec.required_ruby_version = ">= 0"
	
	spec.add_dependency "msgpack", "~> 1.0"
	spec.add_dependency "relaxo", "~> 1.5"
	
	spec.add_development_dependency "bake"
	spec.add_development_dependency "bake-bundler"
	spec.add_development_dependency "bake-modernize"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.4"
end
