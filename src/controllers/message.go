package controllers

import (
	_ "github.com/jinzhu/gorm/dialects/postgres"
	_ "github.com/lib/pq"
)

// Message struct provides a standard format for response messages to requests' status
type Message struct {
	Response     string
	StatusCode   uint
	ErrorMessage error
}

var message Message
