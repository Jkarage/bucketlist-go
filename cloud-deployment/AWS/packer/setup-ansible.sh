#!/bin/bash

set -e
set -o pipefail

setup_ansible() {
	sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo apt-add-repository ppa:ansible/ansible
    sudo apt-get update
    sudo apt-get install -y ansible postgresql postgresql-contrib
}

main() {
    setup_ansible
}

main "$@"
