run:
	go run .
	
build:
	go build -o ./out/gnome-dav-support .

build-amd64:
	GOOS=linux GOARCH=amd64 go build -o ./out/gnome-dav-support .

build-arm:
	GOOS=linux GOARCH=arm go build -o ./out/gnome-dav-support .

clean:
	rm -rf ./out

clean-release: clean
	rm -rf ./release

release-arm: clean build-arm
	mkdir --parent ./release
	cp ./install.sh ./out
	zip --junk-paths ./release/gnome-dav-support-arm.zip ./out/*

release-amd64: clean build-amd64
	mkdir --parent ./release
	cp ./install.sh ./out
	zip --junk-paths ./release/gnome-dav-support-amd64.zip ./out/*

release: clean-release release-amd64 release-arm
