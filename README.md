# GNOME DAV Support Shim
CardDAV, CalDAV, etc support for GNOME.

## What is this ?

Gnome's online account integration doesn't support standalone CalDAV and CardDAV servers, but does support NextCloud which uses CalDAV/CardDAV underneath. This shim emulates NextCloud and redirects DAV URLs to your DAV server of choice. Inspired from [this.](https://gist.github.com/apollo13/f4fc8f33a2700dffb9e11c1b056c53ba)

I'm using it with self hosted Radicale but it can be used with Fastmail or any other DAV implementation.

## How to use it ?

Install a Go development environment. Then:

```bash
git clone https://github.com/IceWreck/Gnome-DAV-Support-Shim.git
cd Gnome-DAV-Support-Shim
make build
install.sh
```

Then add a new NextCloud account in Gnome Online Accounts. Set the URL to `http://localhost:8223`, and your dav server username and password in required fields.

The install script sets up a systemd service that starts when you log in. It defaults to Fastmail. You can specify custom DAV URLs like so:

```bash
install.sh --cal https://dav.abifog.com/IceWreck --card https://dav.abifog.com/IceWreck
```

To uninstall, run `install.sh --uninstall`.

## An alternative method

I've been doing this for years but got tired of it.

Yes, you can install evolution mail client from your distro's repos, add your DAV server from there and then uninstall evolution and keep using your DAV servers from Gnome Contacts and Gnome Calendar. But if you want to modify or add those again, you gotta repeat the process.

