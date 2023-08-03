# GNOME DAV Support Shim
CardDAV, CalDAV, etc support for GNOME.

## What is this ?

Gnome's online account integration doesn't support standalone CalDAV and CardDAV servers, but does support NextCloud which uses CalDAV/CardDAV underneath. This shim emulates NextCloud and redirects DAV URLs to your DAV server of choice. Inspired from [this.](https://gist.github.com/apollo13/f4fc8f33a2700dffb9e11c1b056c53ba)

I'm using it with self hosted Radicale but it can be used with Fastmail or any other DAV implementation.

## How to use it ?

```bash
# Assuming you're on an amd64 system (ARM is also supported):
wget https://github.com/IceWreck/Gnome-DAV-Support-Shim/releases/download/v0.1.0/gnome-dav-support-amd64.zip
unzip gnome-dav-support-amd64.zip
```

Now simply run the install script, which sets up a systemd service that starts when you log in. If you are using Fastmail:

```bash
./install.sh
```

... or if you're using a different Cal/CardDAV service, run something to this effect:

```bash
./install.sh --cal "${caldav-service-url}" --card "${carddav-service-url}"
```

_Note: There is no need for `sudo`._

Then add a new NextCloud account in Gnome Online Accounts. Set the URL to `http://localhost:8223`, and your DAV server username and password in required fields.

To uninstall, run `install.sh --uninstall`.

## An alternative method

I've been doing this for years but got tired of it.

Yes, you can install evolution mail client from your distro's repos, add your DAV server from there and then uninstall evolution and keep using your DAV servers from Gnome Contacts and Gnome Calendar. But if you want to modify or add those again, you gotta repeat the process.
