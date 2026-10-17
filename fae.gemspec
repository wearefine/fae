$:.push File.expand_path('../lib', __FILE__)

# require 'fae/version'

Gem::Specification.new do |s|
  s.name        = 'fae-rails'
  # TODO figure this out:
  # # #17 0.692 [!] There was an error while loading `fae.gemspec`: cannot load such file -- fae/version. Bundler cannot continue.
  # Hardcoding the version for now, because the previous error is happening, likely do to something
  # Going wrong with the Zeitwerk autoloader...
  s.version     = '4.0'
  s.authors     = ['FINE']
  s.email       = ['fae@wearefine.com']
  s.homepage    = 'https://github.com/wearefine/fae'
  s.summary     = 'CMS for Rails. For Reals.'
  s.description = 'CMS for Rails. For Reals.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.md']

  # Rails dependencies
  s.add_dependency 'rails', '>= 8.0'
  s.add_dependency 'propshaft', '>= 1.1'
  s.add_dependency 'importmap-rails', '>= 1.2.1'
  s.add_dependency 'stimulus-rails'
  s.add_dependency 'turbo-rails', '>= 2.0'

  # other dependencies
  s.add_dependency 'acts_as_list', '~> 0.9.11'
  s.add_dependency 'browser', '~> 2.5.3'
  s.add_dependency 'carrierwave'
  s.add_dependency 'csv'
  s.add_dependency 'devise'
  s.add_dependency 'mini_magick'
  s.add_dependency 'judge', '~> 3.1.0'
  s.add_dependency 'judge-simple_form', '~> 1.1.0'
  s.add_dependency 'kaminari'
  s.add_dependency 'remotipart', '~> 1.4.0'
  s.add_dependency 'simple_form', '<= 5.1'
  s.add_dependency 'slim'
  s.add_dependency 'devise-two-factor'
  s.add_dependency 'rqrcode'
  s.add_dependency 'ruby-openai'
  s.add_dependency 'settingslogic'

  # Build the prebuilt admin CSS and JS (rake fae:build). jQuery, jQuery UI and the other
  # libraries the legacy JS bundles are resolved from these gems at build time only.
  s.add_development_dependency 'sass-embedded'
  s.add_development_dependency 'jquery-rails', '~> 4.3.1'
  s.add_development_dependency 'jquery-ui-rails', '~> 6.0.1'
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
end
