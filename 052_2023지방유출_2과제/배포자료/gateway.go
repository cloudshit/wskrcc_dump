package main

import (
    "fmt"
    "net/http"
)

func health(w http.ResponseWriter, req *http.Request) {
    fmt.Fprint(w, "up")
}

func mygateway(w http.ResponseWriter, req *http.Request) {
    fmt.Fprint(w, "FORWARD")
}

func main() {
    http.HandleFunc("/health", health)
    http.HandleFunc("/v1/gateway", mygateway)
    http.ListenAndServe(":8080", nil)
}