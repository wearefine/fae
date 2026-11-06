# Fae

## Docker

This project runs in Docker. Run Ruby, Rails, bundle, and rspec commands through `docker compose`, not on the host. Full setup notes: [docs/contributing/docker_local_setup.md](docs/contributing/docker_local_setup.md).

- The `app` service's working directory is `/app/spec/dummy` (the dummy Rails app). Pass `-w /app` for engine-level commands like rspec.
- The container sets `RAILS_ENV=development`, so test commands must pass `RAILS_ENV=test` explicitly.
- When the stack is already up, use `exec` instead of `run` to avoid starting a new container.

```sh
# Run specs (xvfb-run is needed for feature specs that use a headless browser)
docker compose exec -e RAILS_ENV=test -w /app app xvfb-run -a bundle exec rspec spec/models/fae/video_spec.rb

# Dummy app migrations (dev and test DBs)
docker compose exec app bundle exec rails db:migrate
docker compose exec -e RAILS_ENV=test app bundle exec rails db:migrate
```
