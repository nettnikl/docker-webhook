[Webhook](https://github.com/adnanh/webhook/) Dockerized
=================

Small (2.5 MB), cross plattform (amd64, arm/v7, arm64) and secure (minimal, distroless, reproducible) docker image that can be used to simply automate a lot of things using webhooks.
Mostly useful as base image for your own automation - see the compose example, which can be used to deploy your docker compose files in GitOps style on the host.

## Usage

### Simple
The simplest usage of [almir/webhook](https://hub.docker.com/r/almir/webhook/) image is for one to host the hooks JSON file on their machine and mount the directory in which those are kept as a volume to the Docker container:
```shell
docker run -d -p 9000:9000 -v ./webhooks:/etc/webhook --name=webhook ghcr.io/nettnikl/docker-webhook:master
```

### For GitOps
If you are looking for a GitOps like solution, you can use the compose version. It includes a shell, the Docker CLI and Docker Compose CLI.
```shell
docker run -d -p 9000:9000 -v ./webhooks:/etc/webhook --name=webhook ghcr.io/nettnikl/docker-webhook:compose
```

### For GitOps, using Docker Compose
```yaml
services:
  webhook:
    image: ghcr.io/nettnikl/docker-webhook:compose
    restart: unless-stopped
    ports: [9000:9000]
    environment:
      DOCKER_HOST: tcp://docker-socket-proxy:2375
    volumes:
      - ./webhooks:/etc/webhook

  docker-socket-proxy:
    image: tecnativa/docker-socket-proxy
    privileged: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      LOG_LEVEL: "warning"
      POST: 1
      CONTAINERS: 1
      IMAGES: 1
      INFO: 1
      NETWORKS: 1
      SERVICES: 1
      TASKS: 1
      VOLUMES: 1
```

### Custom
Another method of using this Docker image is to create your own simple `Dockerfile`:
```docker
FROM ghcr.io/nettnikl/docker-webhook:master
COPY hooks.json.example /etc/webhook/hooks.json
```

This `Dockerfile` and `hooks.json.example` files should be placed inside the same directory. After that run `docker build -t my-webhook-image .` and then start your container:
```shell
docker run -d -p 9000:9000 --name=webhook my-webhook-image -verbose -hooks=/etc/webhook/hooks.json -hotreload
```

Additionally, one can specify the parameters to be passed to [webhook](https://github.com/adnanh/webhook/) in `Dockerfile` simply by adding one more line to the previous example:
```docker
FROM ghcr.io/nettnikl/docker-webhook:master
COPY hooks.json.example /etc/webhook/hooks.json
CMD ["-verbose", "-hooks=/etc/webhook/hooks.json", "-hotreload"]
```

Now, after building your Docker image with `docker build -t my-webhook-image .`, you can start your container by running just:
```shell
docker run -d -p 9000:9000 --name=webhook my-webhook-image
```
