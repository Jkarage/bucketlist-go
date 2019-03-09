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
    echo "Go Installation & Setup Completed Successfully..."
}

setup_go_app() {
    echo "exporting GOPATH..."
    export GOPATH=/bucketlist-go
    echo "exported GOPATH..."
    echo "Downloading and installing supporting Go packages..."
    go get -u github.com/gorilla/handlers
    go get -u github.com/auth0/go-jwt-middleware
	go get -u github.com/dgrijalva/jwt-go
    go get -u github.com/gorilla/mux
	go get -u github.com/jinzhu/gorm
	go get -u github.com/lib/pq
    go get -u github.com/joho/godotenv
    go get -u github.com/jinzhu/gorm/dialects/postgres
	go get -u golang.org/x/crypto/bcrypt
    echo "Downloading and installing supporting Go packages finished..."
    go install controllers
    go install routes
    go install services
    echo "Package Installation Complete..."
}

main() {
    install_go
    setup_go
}

main "$@"