# Demo: Using the demo docker container

## What is it?

A docker container that runs the demo in a container.  All you have to do is run it, open your browser and navigate to localhost:5000.

## Instructions

1. cd to this directory
2. Run create-docker.sh
3. docker run -p 5000:5000 --name <container-name> portal2semp
5. start your browser with CORS turned off (e.g. chrome --disable-web-security --user-data-dir="./")
6. navigate to "localhost:5000"
