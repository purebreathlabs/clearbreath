FROM golang:1.25-alpine AS builder

WORKDIR /build

ARG VERSION=dev

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w -X main.version=${VERSION}" -o /api ./cmd/api

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /api /api
COPY --from=builder /build/registry /registry

EXPOSE 8080

ENTRYPOINT ["/api"]
