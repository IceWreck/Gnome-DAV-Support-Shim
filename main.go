package main

import (
	"flag"
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

var calDavUrl string
var cardDavUrl string

var wellKnownCardDav = map[string]string {
	"fastmail": "https://carddav.fastmail.com/dav/addressbooks",
	// Can add more services here, pull requests welcome
}

var wellKnownCalDav = map[string]string {
	"fastmail": "https://caldav.fastmail.com/dav/calendars",
	// Can add more services here, pull requests welcome
}

func init() {
	chi.RegisterMethod("PROPFIND")
}

func main() {

	var calDavArg string
	var cardDavArg string

	flag.StringVar(&calDavArg, "cal", "fastmail", "The CalDAV redirect URL")
	flag.StringVar(&cardDavArg, "card", "fastmail", "The CardDAV redirect URL")

	flag.Parse()

	wkCal, exists := wellKnownCalDav[calDavArg]
	if (exists) {
		calDavUrl = wkCal
	} else {
		calDavUrl = calDavArg
	}

	wkCard, exists := wellKnownCardDav[cardDavArg]
	if (exists) {
		cardDavUrl = wkCard
	} else {
		cardDavUrl = cardDavArg
	}

	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.StripSlashes)

	r.Get("/", func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("GNOME DAV Support Shim")) })
	r.MethodFunc("PROPFIND", "/.well-known/{davType}", redirect)
	r.Route("/remote.php", func(r chi.Router) {
		r.HandleFunc("/webdav", func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("")) })
		r.MethodFunc("PROPFIND", "/{davType}", redirect)
	})
	fmt.Println("Starting at :8223")
	http.ListenAndServe(":8223", r)
}

func redirect(w http.ResponseWriter, r *http.Request) {
	davType := chi.URLParam(r, "davType")
	switch davType {
	case "caldav":
		http.Redirect(w, r, calDavUrl, http.StatusTemporaryRedirect)
	case "carddav":
		http.Redirect(w, r, cardDavUrl, http.StatusTemporaryRedirect)
	default:
		w.Write([]byte("Not Implemented Yet"))
	}
}
