$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "seed_migration/version"

# Describe your gem and declare its dependencies:

Gem::Specification.new do |s|
  s.name = "seed_migration"
  s.version = SeedMigration::VERSION
  s.authors = ["Andy O'Neill", "Daniel Schwartz", "Ilya Rubnich", "Pierre Jambet", "Sunny Ng", "Bart Agapinan"]
  s.email = ["bart@sonic.net"]
  s.description = "Rails gem for Data Migrations"
  s.summary = "Rails Data Migration"
  s.homepage = "http://github.com/viamin/seed_migration"
  s.license = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]

  s.add_development_dependency "pry"
  s.add_development_dependency "rspec-rails", "~> 5.1"
  s.add_development_dependency "rspec-mocks"
  s.add_development_dependency "test-unit", "~> 3.0"
  s.add_development_dependency "codeclimate-test-reporter"
end
