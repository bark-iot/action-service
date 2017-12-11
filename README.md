# action-service

See `bark` repository for instructions.

# API docs
- to view go to [http://localhost/actions/docs](http://localhost/actions/docs)
- to build run `cd docs && mkdocs build`

# Migrations
- `docker-compose run action-service ./cli db_migrate`

# Run tests
- `dc run action-service rspec`