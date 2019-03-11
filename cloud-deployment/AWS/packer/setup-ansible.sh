#!/bin/bash

set -e
set -o pipefail

setup_ansible() {
    sudo rm /var/lib/apt/lists/lock
    sudo rm /var/cache/apt/archives/lock
    sudo rm /var/lib/dpkg/lock
    sudo dpkg --configure -a
	sudo apt-get update
    sudo apt-get install -y postgresql postgresql-contrib
}

main() {
    setup_ansible
}

main "$@"
