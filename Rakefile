require "bundler/gem_tasks"
require "rspec/core/rake_task"

# For RSpec
RSpec::Core::RakeTask.new(:spec)

task :console do
	require 'pry'
	
	require_relative 'lib/relaxo/model'
	
	DB = Relaxo.connect(File.join(__dir__, 'testdb'))
	
	Pry.start
end

task :default => :spec
