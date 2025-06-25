package main

import (
    "fmt"
    "net/http"
)

func health(w http.ResponseWriter, req *http.Request) {
    fmt.Fprint(w, "up")
}

func myapi(w http.ResponseWriter, req *http.Request) {
    fmt.Fprint(w, "api")
}

func main() {
    http.HandleFunc("/health", health)
    http.HandleFunc("/v1/api", myapi)
    http.ListenAndServe(":8080", nil)
}