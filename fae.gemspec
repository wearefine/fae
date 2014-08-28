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
  s.add_dependency "simple_form", '~> 3.0.2'
  s.add_dependency "jquery-rails", '~> 3.1.1'

  s.add_dependency "sass-rails", "~> 4.0.3"
  s.add_dependency "coffee-rails"
  s.add_dependency "uglifier"
  s.add_dependency "jquery-ui-rails", '~> 4.2.1'
  s.add_dependency "remotipart"

  s.add_development_dependency "mysql2"
  s.add_development_dependency "thin"
  s.add_development_dependency "better_errors"
  s.add_development_dependency "binding_of_caller"
  s.add_development_dependency "rails-perftest"
  s.add_development_dependency "ruby-prof"
end
