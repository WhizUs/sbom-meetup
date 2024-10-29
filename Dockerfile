FROM golang:1.23.2 AS builder

WORKDIR /app

COPY . .

RUN go build -o bin

FROM scratch

COPY --from=builder /app/bin /

CMD ["/bin"]