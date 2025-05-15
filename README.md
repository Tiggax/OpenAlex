# OpenAlex Local Server

This is a local version of the [OpenAlex](https://openalex.org/) Database.
The database was  downloaded into the snapshot folder using `aws`.
The local version of the `oxigraph-cli` is downloaded in the oxigraph folder.
The instance of a Graph Database is located in the database folder.

A user `open_alex_admin` was created to run the server.
The whole OpenAlex folder is contained in the `open_alex` group, so there is no reading of files outside of the folders.

A systemd service was created (`open-alex.service`) to run the server.
As the server is under SELinux, binary needs to be relabeld to be able to run, by running:

```bash
sudo chcon -t bin_t /storage/OpenAlex/oxigraph/bin/oxigraph
```

# FIREWALL

Firewall was needed to passtrhoruhg the port with:
```bash
sudo semanage port -a -t http_port_t -p tcp 7878
sudo firewall-cmd --add-port=7878/tcp --permanent
sudo firewall-cmd --reload
```

The server is available on port 7878.
It contains a basic querying server, that is read only.

TODO database syncing and updating -switch between read only and mutable server.



# SETUP
proxied on nginx and snapd with certbot
