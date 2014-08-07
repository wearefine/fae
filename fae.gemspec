$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fae/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fae"
  s.version     = Fae::VERSION
  s.authors     = ["FINE"]
  s.email       = ["james@finedesigngroup.com"]
  s.homepage    = "http://www.wearefine.com"
  s.summary     = "FINE's Admin Engine"
  s.description = "FINE's Admin Engine"
  s.license     = ""

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.4"

  s.add_dependency "devise", "~> 3.2.4"

  # s.add_development_dependency "sqlite3"
end
