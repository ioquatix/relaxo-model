
Dir.chdir("../") do
	require './lib/relaxo/model/version'

	Gem::Specification.new do |s|
		s.name = "relaxo-model"
		s.version = Relaxo::Model::VERSION::STRING
		s.author = "Samuel Williams"
		s.email = "samuel.williams@oriontransfer.co.nz"
		s.homepage = "http://www.oriontransfer.co.nz/gems/relaxo"
		s.platform = Gem::Platform::RUBY
		s.summary = "Relaxo Model is a high level business logic framework for CouchDB/Relaxo."
		s.files = FileList["{bin,lib,test}/**/*"] + ["README.md"]

		s.add_dependency("relaxo")
		s.add_dependency("money")

		s.has_rdoc = "yard"
	end
end
