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

// User struct is the user blueprint
type User struct {
	gorm.Model
	FirstName   string `json:"first_name"`
	Surname     string `json:"surname"`
	UserEmail   string `json:"email"`
	Password    string `json:"password"`
	Bucketlists []Bucketlist
}

// Item struct is the bucketlist items' blueprint
type Item struct {
	gorm.Model
	ItemName        string `json:"name"`
	ItemDescription string `json:"description"`
	BucketlistName  string
}

// Bucketlist struct is the blueprint for all bucketlists
type Bucketlist struct {
	gorm.Model
	BucketlistName  string `json:"name"`
	BucketlistItems []Item
	UserEmail       string
}

// Message struct provides a standard format for response messages to requests' status
type Message struct {
	Response   string
	StatusCode uint
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

// Migrate function helps with the database migrations
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

// CreateEndPoint is a POST handler that posts a new user
func CreateEndPoint(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()

	if err != nil {
		panic("Connection to database failed")
	}

	w.Header().Set("Content-Type", "application/json")

	password := []byte(r.FormValue("password"))
	hashedPassword, _ := bcrypt.GenerateFromPassword(password, bcrypt.DefaultCost)

	user = User{
		FirstName: r.FormValue("first_name"),
		Surname:   r.FormValue("surname"),
		UserEmail: r.FormValue("email"),
		Password:  string(hashedPassword),
	}

	db.Debug().Create(&user)
	fmt.Println("User persisted vizuri")

}

// EditEndPoint is a PUT handler that edits a database record
func EditEndPoint(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()
	if err != nil {
		panic("Connection to database failed")
	}
	vars := mux.Vars(r)
	name := vars["name"]

	password := []byte(r.FormValue("password"))
	hashedPassword, _ := bcrypt.GenerateFromPassword(password, bcrypt.DefaultCost)

	db.Debug().Model(&user).Where("first_name = ?", name).Update(User{
		FirstName: r.FormValue("first_name"),
		Surname:   r.FormValue("surname"),
		UserEmail: r.FormValue("email"),
		Password:  string(hashedPassword),
	})
	fmt.Println("User updated successfully")

}

// AllEndPoint is a GET handler that fetches all users in the database
func AllEndPoint(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()
	if err != nil {
		panic("Connection to database failed")
	}
	w.Header().Set("Content-Type", "application/json")

	var users []User
	db.Find(&users)
	json, _ := json.Marshal(users)
	w.Write([]byte(json))

}

// SearchEndpoint is a GET handler for searching for a specific user from the
// database using a first name as the unique parameter
func SearchEndpoint(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()
	if err != nil {
		panic("Connection to database failed")
	}
	w.Header().Set("Content-Type", "application/json")

	vars := mux.Vars(r)
	name := vars["name"]

	var fetchedUsers []User
	db.Where("first_name = ?", name).First(&fetchedUsers)

	var message Message

	if len(fetchedUsers) == 0 {
		message.Response = "the user you are searching for does not exist"
		message.StatusCode = 404
		jsonmessage, _ := json.Marshal(message)
		w.Write([]byte(jsonmessage))
	} else {
		json, _ := json.Marshal(fetchedUsers)
		w.Write([]byte(json))
	}

}

// DeleteEndPoint handler deletes a user record using a given user name
func DeleteEndPoint(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()
	if err != nil {
		panic("Connection to database failed")
	}
	w.Header().Set("Content-Type", "application/json")

	vars := mux.Vars(r)
	name := vars["name"]

	var user User
	db.Debug().Where("first_name = ?", name).Delete(&user)

	var message Message

	message.Response = "user deleted successfully"
	message.StatusCode = 200
	jsonmessage, _ := json.Marshal(message)
	w.Write([]byte(jsonmessage))

}

// Define HTTP request routes
func main() {
	r := mux.NewRouter()
	// r.HandleFunc("/bucketlist", AllEndPoint).Methods("GET")
	r.HandleFunc("/bucketlist", CreateEndPoint).Methods("POST")
	r.HandleFunc("/bucketlist/{name}", EditEndPoint).Methods("PUT")
	r.HandleFunc("/bucketlist", AllEndPoint).Methods("GET")
	r.HandleFunc("/bucketlist/{name}", DeleteEndPoint).Methods("DELETE")
	r.HandleFunc("/bucketlist/{name}", SearchEndpoint).Methods("GET")
	if err := http.ListenAndServe(":3000", r); err != nil {
		log.Fatal(err)
	}
}
