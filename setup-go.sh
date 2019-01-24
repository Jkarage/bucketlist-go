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

main() {
    install_go
}

main "$@"