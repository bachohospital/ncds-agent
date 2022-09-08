#!/bin/sh

docker login -u AGENT -p mSAovKkmiFoz9NjjssU9 registry.gitlab.com/datacenter7/agent-version-three` &
docker pull registry.gitlab.com/datacenter7/agent-version-three:latest
