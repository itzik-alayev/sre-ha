FROM golang:1.16 AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY handler.go .
RUN GOOS=linux go build handler.go

FROM gcr.io/distroless/base-debian10

COPY --from=builder /build/handler /

CMD ["/handler"]
