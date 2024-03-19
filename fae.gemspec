$:.push File.expand_path('../lib', __FILE__)

# require 'fae/version'

Gem::Specification.new do |s|
  s.name        = 'fae-rails'
  # ------
  # > [gems 4/4] RUN bundle install &&  rm -rf vendor/bundle/ruby/*/cache:
  # #17 0.692
  # #17 0.692 [!] There was an error parsing `Gemfile`:
  # #17 0.692 [!] There was an error while loading `fae.gemspec`: cannot load such file -- fae/version. Bundler cannot continue.
  # #17 0.692
  # #17 0.692  #  from /app/fae.gemspec:3
  # #17 0.692  #  -------------------------------------------
  # #17 0.692  #
  # #17 0.692  >  require 'fae/version'
  # #17 0.692  #
  # #17 0.692  #  -------------------------------------------
  # #17 0.692 . Bundler cannot continue.
  # #17 0.692
  # #17 0.692  #  from /app/Gemfile:6
  # #17 0.692  #  -------------------------------------------
  # #17 0.692  #  # development dependencies will be added by default to the :development group.
  # #17 0.692  >  gemspec
  # #17 0.692  #
  # #17 0.692  #  -------------------------------------------
  # ------
  # Hardcoding the version for now, because the previous error is happening, likely do to something
  # Going wrong with the Zeitwerk autoloader...
  s.version     = '3.1.0'
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
  s.add_dependency 'carrierwave'
  s.add_dependency 'devise'
  s.add_dependency 'jquery-ui-rails', '~> 6.0.1'
  s.add_dependency 'mini_magick'
  s.add_dependency 'judge', '~> 3.1.0'
  s.add_dependency 'judge-simple_form', '~> 1.1.0'
  s.add_dependency 'kaminari'
  s.add_dependency 'remotipart', '~> 1.4.0'
  s.add_dependency 'simple_form', '<= 5.1'
  s.add_dependency 'slim'
  s.add_dependency 'devise-two-factor'
  s.add_dependency 'rqrcode'
  s.add_dependency 'slack-notifier'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'rails-perftest'
  s.add_development_dependency 'ruby-prof'
  s.add_development_dependency 'thin'
end
