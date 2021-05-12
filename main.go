package main

import (
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

var serviceMap = map[string]string{
	"radicale-caldav":  "https://dav.abifog.com/IceWreck",
	"radicale-carddav": "https://dav.abifog.com/IceWreck",
	"fastmail-caldav":  "https://caldav.fastmail.com/dav/calendars",
	"fastmail-carddav": "https://carddav.fastmail.com/dav/addressbooks",
}

func init() {
	chi.RegisterMethod("PROPFIND")
}

func main() {

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
		http.Redirect(w, r, serviceMap["radicale-caldav"], http.StatusTemporaryRedirect)
	case "carddav":
		http.Redirect(w, r, serviceMap["radicale-carddav"], http.StatusTemporaryRedirect)
	default:
		w.Write([]byte("Not Implemented Yet"))
	}
}
