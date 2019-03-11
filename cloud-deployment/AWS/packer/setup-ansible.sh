#!/bin/bash

set -e
set -o pipefail

setup_ansible() {
    sudo pkill apt-get
    sudo pkill apt
	sudo apt-get update
    sudo apt-get install -y postgresql postgresql-contrib
}

main() {
    setup_ansible
}

main "$@"
