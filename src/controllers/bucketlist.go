package controllers

import (
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
	_ "github.com/lib/pq"
)

// Bucketlist struct is the blueprint for all bucketlists
type Bucketlist struct {
	gorm.Model
	BucketlistName  string `json:"name" gorm:"not null"`
	BucketlistItems []Item
	UserEmail       string
}

var bucketlist Bucketlist
