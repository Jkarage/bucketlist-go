#!/bin/bash

set -e
set -o pipefail

setup_postgres() {
    # sudo pkill apt-get
    # sudo pkill apt
    sudo dpkg-reconfigure -f noninteractive tzdata
    export DEBIAN_FRONTEND=noninteractive
    sudo rm /var/lib/apt/lists/lock
    sudo rm /var/cache/apt/archives/lock
    sudo rm /var/lib/dpkg/lock
    sudo rm /var/lib/dpkg/lock-frontend 
	sudo apt-get update
    sudo apt-get install -y postgresql postgresql-contrib
}

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
    export GOPATH=~/bucketlist-go
    echo "exported GOPATH..."
    echo "Downloading and installing supporting Go packages..."
    go get -u github.com/gorilla/handlers \
    github.com/auth0/go-jwt-middleware \
    github.com/dgrijalva/jwt-go \
    github.com/gorilla/mux \
    github.com/jinzhu/gorm \
    github.com/lib/pq \
    github.com/joho/godotenv \
    github.com/jinzhu/gorm/dialects/postgres \
    golang.org/x/crypto/bcrypt \
    github.com/davidmukiibi/controllers \
    github.com/davidmukiibi/routes \
    github.com/davidmukiibi/services
    echo "Downloading and installing supporting Go packages finished..."
}

main() {
    install_go
    setup_go_app
    setup_postgres
}

main "$@"
