#!/bin/bash

set -e
set -o pipefail

install_go() {
    sudo su ubuntu && \
    cd ~/bucketlist-go && wget -c https://storage.googleapis.com/golang/go1.11.2.linux-amd64.tar.gz && \
    sudo chown $USER: -R /usr/local && \
    sudo chmod u+w /usr/local && \
    tar -C /usr/local -xvzf go1.11.2.linux-amd64.tar.gz && \
    export PATH=$PATH:/usr/local/go/bin && \
    source $HOME/.profile && \
    sudo rm -rf go1.11.2.linux-amd64.tar.gz && \
    echo "Go Installation & Setup Completed Successfully..."
}

setup_go_app() {
    echo "exporting GOPATH..." && \
    export GOPATH=~/bucketlist-go && \
    echo "exported GOPATH..." && \
    echo "Downloading and installing supporting Go packages..." && \
    cd ~/bucketlist-go && go get -u github.com/gorilla/handlers \
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

setting_env_vars() {
    export DB_HOST=localhost && \
    export DB_DATABASE=kenya && \
    export DB_USER=postgres && \
    export DB_PASS=secretsecretsecret && \
    export SSL_MODE=disable && \
    export DB_TYPE=postgres && \
    export SECRET=some_random_secret_is_not_a_secret
}

install_postgres() {
    sudo apt-get update && \
    sudo apt-get install -y postgresql \
    postgresql-contrib \
    postgresql-client
}

set_up_postgres() {
    touch createdatabase.sql
    cat <<EOF > createdb.sql
    CREATE DATABASE kenya;
EOF
    cp createdatabase.sql /docker-entrypoint-initdb.d
}

set_up_postgres_user_password() {
    sudo su postgres && \
    psql -c "ALTER USER postgres WITH PASSWORD 'secretsecretsecret';"
}

main() {
    setting_env_vars
    install_go
    setup_go_app
    install_postgres
    set_up_postgres
    set_up_postgres_user_password
}

main "$@"
