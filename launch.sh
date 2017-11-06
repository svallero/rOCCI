#!/bin/sh

docker run -d --name rocci -p 11443:11443 --net host  rocci
