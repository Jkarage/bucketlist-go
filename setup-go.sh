#!/bin/bash

set -e
set -o pipefail

install_go() {
    wget -c https://storage.googleapis.com/golang/go1.11.2.linux-amd64.tar.gz
    sudo chown $USER: -R /usr/local
    sudo chmod u+w /usr/local
    tar -C /usr/local -xvzf go1.11.2.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    source $HOME/.profile
    echo "go installation done..."
}

setup_go() {
    go get -u github.com/gorilla/handlers
    echo "this is done 1"
    go get -u github.com/auth0/go-jwt-middleware
    echo "this is done 2"
	go get -u github.com/dgrijalva/jwt-go
    echo "this is done 3"
	go get -u github.com/gorilla/mux
    echo "this is done 4"
	go get -u github.com/jinzhu/gorm
    echo "this is done 5"
	go get -u github.com/lib/pq
    echo "this is done 6"
    go get -u github.com/joho/godotenv
    echo "this is done 7"
    go get -u github.com/jinzhu/gorm/dialects/postgres
    echo "this is done 8"
	go get -u golang.org/x/crypto/bcrypt
    echo "this is done 9"
    cd bucketlist-go && go install controllers && go install routes && go install services
    echo "this is done 10"
}

main() {
    install_go
    setup_go
}

main "$@"
