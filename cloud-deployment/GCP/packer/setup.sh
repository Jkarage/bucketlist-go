#!/bin/bash

set -e
set -o pipefail

install_go() {
	cd /tmp && wget -c https://storage.googleapis.com/golang/go1.11.2.linux-amd64.tar.gz && \
	sudo chown $USER: -R /usr/local && \
	sudo chmod u+w /usr/local && \
	tar -C /usr/local -xvzf go1.11.2.linux-amd64.tar.gz && \
	echo "Go Installation & Setup Completed Successfully..."
}

install_postgres() {
    sudo apt-get update && \
    sudo apt-get install -y postgresql \
    postgresql-contrib \
    postgresql-client && \
    echo "installing postgres server and client completed..."
}

set_up_postgres() {
    touch createdatabase.sql
    cat <<EOF > createdb.sql
    CREATE DATABASE kenya;
    ALTER USER postgres WITH PASSWORD 'secretsecretsecret';
EOF
    cp createdatabase.sql /docker-entrypoint-initdb.d
}

main() {
    install_go
    install_postgres
    set_up_postgres
}

main "$@"
