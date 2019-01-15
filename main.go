package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	jwtmiddleware "github.com/auth0/go-jwt-middleware"
	jwt "github.com/dgrijalva/jwt-go"
	"github.com/gorilla/mux"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
	_ "github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

// User struct is the user blueprint
type User struct {
	gorm.Model
	FirstName   string `json:"first_name" gorm:"not null"`
	Surname     string `json:"surname" gorm:"not null"`
	UserEmail   string `json:"email" gorm:"not null;unique"`
	Password    string `json:"password" gorm:"not null"`
	Bucketlists []Bucketlist
}

// Item struct is the bucketlist items' blueprint
type Item struct {
	gorm.Model
	ItemName        string `json:"name" gorm:"not null"`
	ItemDescription string `json:"description"`
	BucketlistName  string
}

// Bucketlist struct is the blueprint for all bucketlists
type Bucketlist struct {
	gorm.Model
	BucketlistName  string `json:"name" gorm:"not null"`
	BucketlistItems []Item
	UserEmail       string
}

// Message struct provides a standard format for response messages to requests' status
type Message struct {
	Response     string
	StatusCode   uint
	ErrorMessage error
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
var message Message

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
var CreateEndPoint = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
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

	feedback := db.Debug().Create(&user)
	if feedback.Error != nil {
		message.Response = "An error occured!"
		message.ErrorMessage = feedback.Error
		jsonmessage, _ := json.Marshal(message)
		w.Write([]byte(jsonmessage))
	} else {
		message.Response = "New user created successfully"
		message.StatusCode = 200
		message.ErrorMessage = nil
		jsonmessage, _ := json.Marshal(message)
		w.Write([]byte(jsonmessage))
	}

})

// EditEndPoint is a PUT handler that edits a database record
var EditEndPoint = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()
	if err != nil {
		panic("Connection to database failed")
	}
	vars := mux.Vars(r)
	name := vars["name"]

	password := []byte(r.FormValue("password"))
	hashedPassword, _ := bcrypt.GenerateFromPassword(password, bcrypt.DefaultCost)

	feedback := db.Debug().Model(&user).Where("first_name = ?", name).Update(User{
		FirstName: r.FormValue("first_name"),
		Surname:   r.FormValue("surname"),
		UserEmail: r.FormValue("email"),
		Password:  string(hashedPassword),
	})
	if feedback.Error != nil {
		message.Response = "An error occured!"
		message.ErrorMessage = feedback.Error
		jsonmessage, _ := json.Marshal(message)
		w.Write([]byte(jsonmessage))
	} else {
		message.Response = "User Updated successfully"
		message.StatusCode = 200
		// message.ErrorMessage = nil
		jsonmessage, _ := json.Marshal(message)
		w.Write([]byte(jsonmessage))
	}

})

// AllEndPoint is a GET handler that fetches all users in the database
var AllEndPoint = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
	defer r.Body.Close()
	if err != nil {
		panic("Connection to database failed")
	}
	w.Header().Set("Content-Type", "application/json")

	var users []User
	feedback := db.Find(&users)
	if feedback.Error != nil {
		message.Response = "An error occured!"
		message.ErrorMessage = feedback.Error
		jsonmessage, _ := json.Marshal(message)
		w.Write([]byte(jsonmessage))
	} else {
		json, _ := json.Marshal(users)
		w.Write([]byte(json))
	}

})

// SearchEndpoint is a GET handler for searching for a specific user from the
// database using a first name as the unique parameter
var SearchEndpoint = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
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
		// message.ErrorMessage = nil
		jsonmessage, _ := json.Marshal(message)
		w.Write([]byte(jsonmessage))
	} else {
		json, _ := json.Marshal(fetchedUsers)
		w.Write([]byte(json))
	}

})

// DeleteEndPoint handler deletes a user record using a given user name
var DeleteEndPoint = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
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
	message.Response = "user deleted successfully"
	message.StatusCode = 200
	jsonmessage, _ := json.Marshal(message)
	w.Write([]byte(jsonmessage))

})

var mySigningKey = []byte("secret")

/* Handlers */
var GetTokenHandler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	/* Create the token */
	token := jwt.New(jwt.SigningMethodHS256)

	// Create a map to store our claims
	claims := token.Claims.(jwt.MapClaims)

	/* Set token claims */
	claims["admin"] = false
	claims["email"] = user.UserEmail
	claims["exp"] = time.Now().Add(time.Hour * 24).Unix()

	/* Sign the token with our secret */
	tokenString, _ := token.SignedString(mySigningKey)

	/* Finally, write the token to the browser window */
	w.Write([]byte(tokenString))
})

var jwtMiddleware = jwtmiddleware.New(jwtmiddleware.Options{
	ValidationKeyGetter: func(token *jwt.Token) (interface{}, error) {
		return mySigningKey, nil
	},
	SigningMethod: jwt.SigningMethodHS256,
})

// SignIn handler signs in a user with a given email and password
// func SignIn(w http.ResponseWriter, r *http.Request) {
// 	db, err := gorm.Open("postgres", "host=localhost port=5432 user=postgres dbname=kenya sslmode=disable")
// 	defer r.Body.Close()
// 	if err != nil {
// 		panic("Connection to database failed")
// 	}
// 	w.Header().Set("Content-Type", "application/json")

// 	loginUser := r.FormValue("email")

// 	var fetchedUsers []User

// 	db.Where("user_email = ?", loginUser).First(&fetchedUsers)

// 	loginpassword := []byte(r.FormValue("password"))
// 	loginhashedPassword, _ := bcrypt.GenerateFromPassword(loginpassword, bcrypt.DefaultCost)

// 	fmt.Println(fetchedUsers)
// 	fmt.Println(fetchedUsers[0].Password)
// 	fmt.Println(string(loginhashedPassword))
// 	if len(fetchedUsers) == 0 {
// 		message.Response = "Invalid email or password"
// 		message.StatusCode = 400
// 		jsonmessage, _ := json.Marshal(message)
// 		w.Write([]byte(jsonmessage))
// 	} else if fetchedUsers[0].Password != string(loginhashedPassword) {
// 		message.Response = "Invalid email or password"
// 		message.StatusCode = 400
// 		jsonmessage, _ := json.Marshal(message)
// 		w.Write([]byte(jsonmessage))
// 	} else {
// 		json, _ := json.Marshal(fetchedUsers)
// 		w.Write([]byte(json))
// 	}
// }

// Define HTTP request routes
func main() {
	r := mux.NewRouter()
	r.Handle("/bucketlist", jwtMiddleware.Handler(AllEndPoint)).Methods("GET")
	r.Handle("/bucketlist", jwtMiddleware.Handler(CreateEndPoint)).Methods("POST")
	r.Handle("/bucketlist/{name}", jwtMiddleware.Handler(EditEndPoint)).Methods("PUT")
	r.Handle("/bucketlist", jwtMiddleware.Handler(AllEndPoint)).Methods("GET")
	r.Handle("/bucketlist/{name}", jwtMiddleware.Handler(DeleteEndPoint)).Methods("DELETE")
	r.Handle("/bucketlist/{name}", jwtMiddleware.Handler(SearchEndpoint)).Methods("GET")
	r.Handle("/token", GetTokenHandler).Methods("GET")
	// r.HandleFunc("/signin", SignIn).Methods("POST")

	if err := http.ListenAndServe(":3000", r); err != nil {
		log.Fatal(err)
	}
}
