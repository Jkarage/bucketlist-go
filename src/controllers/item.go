package controllers

import (
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
	_ "github.com/lib/pq"
)

// Item struct is the bucketlist items' blueprint
type Item struct {
	gorm.Model
	ItemName        string `json:"name" gorm:"not null"`
	ItemDescription string `json:"description"`
	BucketlistName  string
}
