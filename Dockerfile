FROM golang:1.20-alpine3.16 AS builder

WORKDIR /build
RUN adduser -u 10001 -D app-runner

ENV GOPROXY https://goproxy.cn
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -a -o httpserver .

FROM alpine:3.16 AS final

WORKDIR /app
COPY --from=builder /build/httpserver /app/
#COPY --from=builder /build/config /app/config
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

USER app-runner

EXPOSE 8000

ENTRYPOINT ["/app/httpserver", "chat"]
