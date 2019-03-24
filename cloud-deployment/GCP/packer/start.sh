#!/bin/bash
set -e
set -o pipefail

export_env_vars() {
    echo "Exporting env vars..."
    export GOPATH=$HOME/bucketlist-go
    export GOROOT=/usr/local/go
	export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
	# export PATH=$PATH:/usr/local/go/bin
	export DB_HOST=localhost
	export DB_DATABASE=kenya
	export DB_USER=postgres
	export DB_PASS=secretsecretsecret
	export SSL_MODE=disable
	export DB_TYPE=postgres
	export SECRET=some_random_secret_is_not_a_secret
}

downloading_packages() {
    echo "Downloading and installing supporting Go packages..." && \
    cd $GOPATH && go get -u github.com/gorilla/handlers \
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

start_app() {
    echo "Starting the application..."
    cd $GOPATH && go run main.go
}
main() {
    export_env_vars
    downloading_packages
    start_app
}

main "$@"
