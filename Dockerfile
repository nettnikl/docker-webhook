# Dockerfile for https://github.com/adnanh/webhook
FROM golang:alpine AS build

LABEL maintainer="Almir Dzinovic <almir@dzinovic.net>"

WORKDIR /go/src/github.com/adnanh/webhook

ARG WEBHOOK_VERSION=2.8.2

RUN apk add --no-cache \
    curl \
    gcc \
    libc-dev \
    libgcc

RUN curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
    tar -xzf webhook.tar.gz --strip 1 && \
    go mod download && \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/webhook


FROM alpine

WORKDIR /etc/webhook

RUN apk add --no-cache bash curl docker-cli docker-compose git

COPY --from=build /usr/local/bin/webhook /usr/local/bin/webhook

VOLUME ["/etc/webhook"]
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/webhook"]
CMD ["-hooks=/etc/webhook/hooks.yaml"]
