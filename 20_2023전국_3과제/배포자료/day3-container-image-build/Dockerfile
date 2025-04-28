FROM golang:1.18 AS build

WORKDIR /source

COPY src/ ./

RUN go mod tidy \
 && go mod download \
 && go build -o ./main

FROM ubuntu:22.10

WORKDIR /app

COPY --from=build /source/main ./

RUN chmod +x ./main

ENTRYPOINT ["./main"]