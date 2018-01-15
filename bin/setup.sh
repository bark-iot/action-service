#!/bin/bash
docker-compose run action-service bundle
docker-compose run action-service bundle exec ./cli db_migrate
docker-compose run action-service bundle exec ./cli db_seed
cd ../action-service/docs && mkdocs build # build api doc