package main

import (
    "fmt"
    "net/http"
)

func health(w http.ResponseWriter, req *http.Request) {
    fmt.Fprint(w, "up")
}

func dummy(w http.ResponseWriter, req *http.Request) {
    fmt.Fprint(w, "dummy")
}

func main() {
    http.HandleFunc("/health", health)
    http.HandleFunc("/v1/dummy", dummy)
    http.ListenAndServe(":8080", nil)
}