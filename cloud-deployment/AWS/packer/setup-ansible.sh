#!/bin/bash

set -e
set -o pipefail

setup_ansible() {
    sudo rm /var/lib/apt/lists/lock
    sudo dpkg --configure -a
    sudo apt-get clean
	sudo apt-get update
    sudo apt-get install -y postgresql postgresql-contrib
}

main() {
    setup_ansible
}

main "$@"
