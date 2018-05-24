package main

import(
	"fmt"
	"net/http"
)

func mainHandler() http.HandlerFunc{
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
		fmt.Fprintf(w, "Hello CircleCI!")
	})
}

func main(){
	http.HandleFunc("/", mainHandler())
	http.ListenAndServe(":8080", nil)
}
