#!/bin/bash

cd docker-build
if [ -d portal2semp ]; then
  rm -rf portal2semp
fi
git clone git@github.com:solacese/portal2semp.git
cd ..
docker build -t portal2semp .
