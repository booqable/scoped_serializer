$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "scoped_serializer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "scoped_serializer"
  s.version     = ScopedSerializer::VERSION
  s.authors     = ["Arjen Oosterkamp"]
  s.email       = ["mail@arjen.me"]
  s.homepage    = "https://github.com/booqable/scoped_serializer"
  s.summary     = "Scoped serializers for Rails"
  s.description = "Scoped serializers for Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 4.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "with_model"
  s.add_development_dependency 'rspec'
end
