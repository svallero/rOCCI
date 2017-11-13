#!/bin/sh

docker stop rocci
docker rm rocci

docker run -d --name rocci -p 11443:11443 --net host  --hostname vdummy01.to.infn.it svallero/rocci
