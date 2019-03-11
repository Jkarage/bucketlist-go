#!/bin/bash

set -e
set -o pipefail

setup_ansible() {
    sudo killall apt apt-get
    sudo apt-get clean
	sudo apt-get update
    sudo apt-get install -y postgresql postgresql-contrib
}

main() {
    setup_ansible
}

main "$@"
