#!/bin/bash
set -e
set -o pipefail


start_app() {
    cd ~/bucketlist-go && go run main.go
}
main() {
    start_app
}

main "$@"
