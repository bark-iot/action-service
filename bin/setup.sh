#!/bin/bash
docker-compose run action-service bundle
docker-compose run action-service bundle exec ./cli db_migrate
cd ../action-service/docs && mkdocs build # build api doc