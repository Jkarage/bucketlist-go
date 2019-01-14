package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
	_ "github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

// bucketlist, create, edit, delete a bucketlist.
// create a user(s) who owns the bucketlists they create.

type User struct {
	gorm.Model
	// ID        uint   `gorm:"primary_key"`
	FirstName string `json:"first_name"`
	Surname   string `json:"surname"`
	UserEmail string `json:"email"`
	Password  string `json:"password"`
}

type Item struct {
	gorm.Model
	// id          uint
	ItemName        string `json:"name"`
	ItemDescription string `json:"description"`
	BucketlistName  string
}

type Bucketlist struct {
	gorm.Model
	// id              uint
	BucketlistName  string `json:"name"`
	BucketlistItems []Item
	UserEmail       string
}

// // Establish a connection to database
// func Connect(server, database string) {
// 	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
// 	if err != nil {
// 		panic("Failed to connect to the database...")
// 		fmt.Println(err)
// 	} else {
// 		fmt.Println("Connection to the database successful...")
// 	}
// 	defer db.Close()
// }

var user User
var item Item
var bucketlist Bucketlist

func Migrate() {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	if err != nil {
		panic("Failed to connect database...")
	}
	db.AutoMigrate(&user, &item, &bucketlist)
	db.Debug().Model(&item).AddForeignKey("bucketlist_name", "bucketlists(bucketlist_name)", "CASCADE", "CASCADE")
	db.Debug().Model(&bucketlist).AddForeignKey("user_email", "users(user_email)", "CASCADE", "CASCADE")

	fmt.Println("Migration successful...")
	defer db.Close()
}

// init is going to have the DB connections and any one-time tasks
func init() {
	// server := "postgres"
	// database := "kenya"
	// Connect(server, database)
	Migrate()
}

// CreateEndPoint function is a POST handler for a new movie
func CreateEndPoint(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()

	// w.Header().Set("Content-Type", "application/json")

	password := []byte(r.FormValue("password"))
	hashedPassword, _ := bcrypt.GenerateFromPassword(password, bcrypt.DefaultCost)

	user = User{
		FirstName: r.FormValue("first_name"),
		Surname:   r.FormValue("surname"),
		Email:     r.FormValue("email"),
		Password:  string(hashedPassword),
	}

	if err != nil {
		panic("Connection to database failed")
	}
	db.Debug().Create(&user)
	fmt.Println("User persisted vizuri")

}

// EditEndPoint function is a PUT handler
func EditEndPoint(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()
	if err != nil {
		panic("Connection to database failed")
	}
	password := []byte(r.FormValue("password"))
	hashedPassword, _ := bcrypt.GenerateFromPassword(password, bcrypt.DefaultCost)
	user = User{
		FirstName: r.FormValue("first_name"),
		Surname:   r.FormValue("surname"),
		Email:     r.FormValue("email"),
		Password:  string(hashedPassword),
	}
	db.Debug().Find(&user, "email = ?", r.FormValue("email"))
	// at this point all it does is find the record it is looking for.
	// Editing the record has not yet been added.

}

// AllEndPoint function is a GET handler
func AllEndPoint(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()
	if err != nil {
		panic("Connection to database failed")
	}
	w.Header().Set("Content-Type", "application/json")
	db.Debug().Find(&user)
	response, _ := json.Marshal(&user)
	usersList := []User{}
	for _, value := range response {
		usersList = append(usersList, value)
		// w.Write(value)
		// fmt.Println(key)
	}
	w.Write(usersList)

}

// Define HTTP request routes
func main() {
	r := mux.NewRouter()
	r.HandleFunc("/bucketlist", AllEndPoint).Methods("GET")
	r.HandleFunc("/bucketlist", CreateEndPoint).Methods("POST")
	r.HandleFunc("/bucketlist", EditEndPoint).Methods("PUT")
	// r.HandleFunc("/bucketlist/{name}", DeleteEndPoint).Methods("DELETE")
	// r.HandleFunc("/bucketlist/{name}", FindEndpoint).Methods("GET")
	if err := http.ListenAndServe(":3000", r); err != nil {
		log.Fatal(err)
	}
}
