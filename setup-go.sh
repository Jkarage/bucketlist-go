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
}

install_postgres() {
    sudo apt-get install -y postgresql libpq-dev postgresql-client postgresql-client-common libssl-dev postgresql-9.5
    sudo service postgresql initdb
    sudo service postgresql start
}

main() {
    install_postgres
    install_go
}

main "$@"
