#!/bin/bash

set -e
set -o pipefail

start_app(){
    go run main.go
}

main() {
    start_app
}

main "$@"
