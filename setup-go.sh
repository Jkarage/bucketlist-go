#!/bin/bash

set -e
set -o pipefail

install_go() {
    wget -c https://storage.googleapis.com/golang/go1.11.2.linux-amd64.tar.gz
    echo "this is done 1"
    sudo chown $USER: -R /usr/local
    echo "this is done 2"
    sudo chmod u+w /usr/local
    echo "this is done 3"
    tar -C /usr/local -xvzf go1.11.2.linux-amd64.tar.gz
    echo "this is done 4"
    export PATH=$PATH:/usr/local/go/bin
    echo "this is done 5"
    source $HOME/.profile
    echo "this is done 6"
    go install controllers routes services
    echo "this is done 7"
    go get -u golang.org/x
    echo "this is done 8"
    go get -u github.com
    echo "this is done 9"
}

main() {
    install_go
}

main "$@"
