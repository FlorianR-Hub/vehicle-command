# syntax = docker/dockerfile:1.2

FROM golang:1.23.0 AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN mkdir build
RUN --mount=type=secret,id=fleet-key_pem,dst=/etc/secrets/fleet-key.pem cp /etc/secrets/fleet-key.pem config/ \
    --mount=type=secret,id=tls-cert_pem,dst=/etc/secrets/tls-cert.pem cp /etc/secrets/tls-cert.pem config/ \
    --mount=type=secret,id=tls-key_pem,dst=/etc/secrets/tls-key.pem cp /etc/secrets/tls-key.pem config/ \
    go build -o ./build ./...

FROM gcr.io/distroless/base-debian12:nonroot AS runtime

COPY --from=build /app/build /usr/local/bin

ENTRYPOINT ["tesla-http-proxy"]
