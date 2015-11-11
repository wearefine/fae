$:.push File.expand_path("../lib", __FILE__)

require "fae/version"

Gem::Specification.new do |s|
  s.name        = "fae-rails"
  s.version     = Fae::VERSION
  s.authors     = ["FINE"]
  s.email       = ["fae@wearefine.com"]
  s.homepage    = "https://bitbucket.org/wearefine/fae"
  s.summary     = "A flexible CMS for Rails"
  s.description = "A flexible CMS for Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  # Rails dependencies
  s.add_dependency "rails", "~> 4.1"
  s.add_dependency "sass-rails", '>= 5.0.3'
  s.add_dependency "sass", '>= 3.4.0'
  s.add_dependency "jquery-rails", '>= 3.1.1'
  s.add_dependency "uglifier"

  # other dependencies
  s.add_dependency "devise", "~> 3.4.1"
  s.add_dependency "simple_form", '~> 3.1.0'
  s.add_dependency "jquery-ui-rails", '~> 4.2.1'
  s.add_dependency "remotipart"
  s.add_dependency "carrierwave", '~> 0.10.0'
  s.add_dependency "rmagick", '~> 2.13.3'
  s.add_dependency "judge", '~> 2.1.0'
  s.add_dependency "judge-simple_form", '~> 1.0.0'
  s.add_dependency 'acts_as_list', '~> 0.4.0'
  s.add_dependency 'browser', '~> 0.8.0'

  s.add_development_dependency "thin"
  s.add_development_dependency "better_errors"
  s.add_development_dependency "binding_of_caller"
  s.add_development_dependency "rails-perftest"
  s.add_development_dependency "ruby-prof"
  s.add_development_dependency "maximus"
  s.add_development_dependency 'appraisal'
end
