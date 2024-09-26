#!/bin/bash
dockerimageid=`docker images | grep xrootd-stageout-server | grep latest | awk '{print $3}'`
docker tag $dockerimageid sdnsense/xrootd-stageout-server:latest
docker push sdnsense/xrootd-stageout-server
