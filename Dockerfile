FROM golang:alpine

RUN mkdir -p /go/app/

COPY . /go/app/

RUN export GOPATH=/go/app

CMD go run main.go

