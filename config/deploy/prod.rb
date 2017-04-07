set :stage, :prod

set :ruby_version, "ruby-2.3.1"
set :gemset, "fae.afinedevelopment.com"
set :deploy_to, "/var/www/rails/fae.afinedevelopment.com/prod"

set :rails_env, 'production'

set :branch, 'master'

set :rvm_ruby_version, "#{fetch(:ruby_version)}@#{fetch(:gemset)}"

set :default_env, {
  path: "/usr/local/rvm/gems/#{fetch(:rvm_ruby_version)}/bin:/usr/local/rvm/bin:/usr/local/rvm/rubies/#{fetch(:ruby_version)}/bin:$PATH",
  ruby_version: fetch(:ruby_version),
  gem_home: "/usr/local/rvm/gems/#{fetch(:rvm_ruby_version)}",
  gem_path: "/usr/local/rvm/gems/#{fetch(:rvm_ruby_version)}",
  bundle_path: "/usr/local/rvm/gems/#{fetch(:rvm_ruby_version)}/bin"  # If you are using bundler.
}
