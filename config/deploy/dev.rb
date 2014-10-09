set :stage, :prod

server 'fae.afinedevelopment.com',
  user: 'fae',
  roles: %w{web app db},
  port: 8022,
  ssh_options: {
    forward_agent: true
  }


set :ruby_version, "ruby-2.1.2"
set :gemset, "dev.fae.afinedevelopment.com"
set :deploy_to, "/var/www/rails/fae.afinedevelopment.com/dev"

set :rails_env, 'remote_development'

set :branch, 'dev'

set :rvm_ruby_version, "#{fetch(:ruby_version)}@#{fetch(:gemset)}"

set :default_env, {
  path: "/usr/local/rvm/gems/#{fetch(:rvm_ruby_version)}/bin:/usr/local/rvm/bin:/usr/local/rvm/rubies/#{fetch(:ruby_version)}/bin:$PATH",
  ruby_version: fetch(:ruby_version),
  gem_home: "/usr/local/rvm/gems/#{fetch(:rvm_ruby_version)}",
  gem_path: "/usr/local/rvm/gems/#{fetch(:rvm_ruby_version)}",
  bundle_path: "/usr/local/rvm/gems/#{fetch(:rvm_ruby_version)}/bin"  # If you are using bundler.
}
