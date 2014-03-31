$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "data_migration/version"

# Describe your gem and declare its dependencies:

Gem::Specification.new do |s|
  s.name          = "data_migration"
  s.version       = DataMigration::VERSION
  s.authors       = ["Andy O'Neill", "Daniel Schwartz"]
  s.email         = ["aoneill@harrys.com",  'daniel@harrys.com']
  s.description   = %q{Rails gem for Data Migrations}
  s.summary       = %q{Rails Data Migration}
  s.homepage      = "http://github.com/harrystech/data_migration"
  s.license       = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 3.2.17"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pg"
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-mocks"

end
