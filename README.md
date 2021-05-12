# GNOME DAV Support Shim
CardDAV, CalDAV, etc support for GNOME.

## What is this ?

Gnome's online account integration doesn't support standalone CalDAV and CardDAV servers, but does support NextCloud which uses CalDAV/CardDAV underneath. This shim emulates NextCloud and redirects DAV URLs to your DAV server of choice. Inspired from [this.](https://gist.github.com/apollo13/f4fc8f33a2700dffb9e11c1b056c53ba)

I'm using it with self hosted Radicale but it can be used with Fastmail or any other DAV implementation.

Shame on Gnome for not supporting open standards even when they have already done all the work and implemented it in another place. 

## How to use it ?

* add your dav server url in serviceMap in `main.go` and point to it in the redirect func
* `make build`
* make a systemd service to run this permanently
* add a new nextcloud account in Gnome Online Accounts, and set url as `localhost:8223`, and your dav server username and password in required fields.


## An alternative method

I've been doing this for years but got tired of it.

Yes, you can install evolution mail client from your distro's repos, add your DAV server from there and then uninstall evolution and keep using your DAV servers from Gnome Contacts and Gnome Calendar. But if you want to modify or add those again, you gotta repeat the process.

