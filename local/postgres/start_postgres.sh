#!/bin/bash

docker run -it --env-file ./development.env -p '5433:5432' -v /home/sidravic/Dropbox/code/workspace/rails_apps/idylmynds/first-hammar/stateful_data/postgres/development:/var/lib/postgresql/data glorious-tower