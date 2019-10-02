$:.push File.expand_path('../lib', __FILE__)

require 'fae/version'

Gem::Specification.new do |s|
  s.name        = 'fae-rails'
  s.version     = Fae::VERSION
  s.authors     = ['FINE']
  s.email       = ['fae@wearefine.com']
  s.homepage    = 'https://github.com/wearefine/fae'
  s.summary     = 'CMS for Rails. For Reals.'
  s.description = 'CMS for Rails. For Reals.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.md']

  # Rails dependencies
  s.add_dependency 'rails', '>= 5.0'
  s.add_dependency 'jquery-rails', '~> 4.3.1'
  s.add_dependency 'sass', '>= 3.4.0'
  s.add_dependency 'sass-rails', '>= 5.0.7'
  s.add_dependency 'uglifier'

  # other dependencies
  s.add_dependency 'acts_as_list', '~> 0.9.11'
  s.add_dependency 'browser', '~> 2.5.3'
  s.add_dependency 'carrierwave', '~> 1.2.2'
  s.add_dependency 'devise', '~> 4.6.2'
  s.add_dependency 'jquery-ui-rails', '~> 6.0.1'
  s.add_dependency 'mini_magick'
  s.add_dependency 'judge', '~> 3.0.0'
  s.add_dependency 'judge-simple_form', '~> 1.1.0'
  s.add_dependency 'kaminari', '~> 1.1.1'
  s.add_dependency 'remotipart', '~> 1.4.0'
  s.add_dependency 'simple_form', '~> 5.0.0'
  s.add_dependency 'slim'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'rails-perftest'
  s.add_development_dependency 'ruby-prof'
  s.add_development_dependency 'thin'
end
