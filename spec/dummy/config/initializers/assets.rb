# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# graphiql-rails' stylesheet uses hsl(var(--x)), which libsass can't parse. The dummy app only
# mounts GraphiQL as a sample route, so it doesn't need to be precompiled.
Rails.application.config.after_initialize do |app|
  app.config.assets.precompile -= %w( graphiql/rails/application.css )
end
