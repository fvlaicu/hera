## Builder image
FROM golang:1.12.1-stretch AS builder

WORKDIR /src

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

RUN GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o /dist/hera

## Final image
FROM debian:stretch-slim

RUN apt update
RUN apt install -y ca-certificates curl

RUN curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-aarch64.tar.gz \
  | tar xvzf - -C /

RUN curl -L -s https://github.com/cloudflare/cloudflared/releases/download/2021.4.0/cloudflared-linux-arm64 -o /bin/cloudflared
RUN chmod +x /bin/cloudflared


COPY --from=builder /dist/hera /bin/

COPY rootfs /

ENTRYPOINT ["/init"]
