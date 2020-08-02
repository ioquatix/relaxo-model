source 'https://rubygems.org'

# Specify your gem's dependencies in relaxo-model.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-bundler"
end

group :development do
	gem "bcrypt"
end
