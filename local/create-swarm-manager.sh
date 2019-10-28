#!/usr/bin/env bash

echo "Creating machine 1 (vm1)"
docker-machine create --driver virtualbox vm1

echo "Creating machine 2 (vm2)"
docker-machine create --driver virtualbox vm2

echo "Creating machine 3 (vm3)"
docker-machine create --driver virtualbox vm3


