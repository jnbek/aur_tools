package main
// DO NOT USE!! This opens sockets and does not close them and causes the machine to go IO bound!!
import (
	"os"
	"fmt"
	"log"
	"strconv"
	"net/http"
	"io/ioutil"
)
const (
    html_file = "/path/to/aur_versions.html"
    pid_file  = "/tmp/serveaur.pid"
)
func main() {
	myarg := os.Args[1]
	if myarg == "start" {
		mypid := os.Getpid()
        thepid := strconv.Itoa(mypid)
        d1 := []byte(thepid)
        err := ioutil.WriteFile(pid_file, d1, 0644)
        check(err)
		http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
			http.ServeFile(w, r, html_file)
		})
		//log.Printf("Listening...")
		http.ListenAndServe(":3000", nil)
	}
	if myarg == "stop" {
		dat, err := ioutil.ReadFile(pid_file)
        check(err)
		pid_str := fmt.Sprintf("%s", string(dat))
		pid, err := strconv.Atoi(pid_str)
        check(err)
        p,err := os.FindProcess(pid)
        check(err)
        er := p.Kill()
        check(er)
	}
}

func check(e error) {
	if e != nil {
		log.Panicln(e)
	}
}
