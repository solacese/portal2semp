FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV HOST=0.0.0.0
RUN apt-get update && \
    apt-get install -y git npm rollup 
COPY docker-build/portal2semp portal2semp
WORKDIR "/portal2semp"
RUN /usr/bin/npm install

ENTRYPOINT ["/usr/bin/npm", "run", "dev"]
