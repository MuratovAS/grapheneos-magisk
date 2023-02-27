# grapheneos-magisk

A small project implementing an update server for `GrapheneOS` with support for `Magisk`. Based on `avbroot`.

!!! The author disclaims responsibility. Everything you do you do on your own at your own peril and risk.

`incremental OTA` is not currently supported.

How it works:
- Generate certificates (first run)
- Download the latest `OTA ROM` for the given device ID (scheduled)
- Download the latest version Magisk
- Patching `rom`
- Extract `img`
- Publication

tested on: Arch, Alpine

## Usage

Required dependencies:
```bash
docker curl jq bash
```

The first start is carried out manually. Certificates are created.
```bash
./auto.sh
```
or
```bash
ID=panther CHANNEL=stable TYPE=ota_update ./auto.sh
```

Launch frontend
```bash
sudo docker-compose up -d
```

Search for new versions of grapheneos. Add a task to `crontab -e`
```bash
10	*/6	*	*	*	/path-to-file/grapheneos-magisk/auto.sh
```

## Usage device

NOTE: still a lot of bugs

Now a rather complicated way of integrating the server with the phone is used. It is implemented by replacing the server.

### Server
`avbroot-frontend` needs to implement TLS and respond to the `releases.grapheneos.org` domain. I solve it by means of `nginx proxy manager`.

You will need a self-signed certificate for this. This can be done like this:
```bash
openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout RootCA.key -out RootCA.pem -subj "/C=RU/CN=Custom-Root-CA"
openssl x509 -outform pem -in RootCA.pem -out RootCA.crt

openssl genrsa -out local.key 2048
openssl req -new -nodes -key local.key -sha256 -out local.csr  -subj "/C=US/ST=Custom/L=Custom/O=local-Certificates/CN=local" -days 3650
openssl x509 -req -sha256 -days 3650 -in local.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial -extfile domains.ext -out local.crt
```

You will also need the file `domains.ext`
```bash
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = releases.grapheneos.org
```
### Device
#### Forwarding
You need to change the `IP` for releases.grapheneos.org. This can be done using `DNS Server`(local use) or `hosts file`. Let's consider the second way.

In the `magisk` settings, enable the `systemless-hosts` mode. after that, in the file `/ets/hosts` we will write the `IP` of your server.
```text
192.168.1.10 releases.grapheneos.org
```
NOTE: there must be an empty line at the end of the file !!!

#### Trust connection

but, this is not enough. You must trust your certificate. Add the user certificate `RootCA.crt` in the system settings.
It is worth noting that the application does not trust user CA. It needs to be made systemic. I use [MagiskTrustUserCerts](https://github.com/NVISOsecurity/MagiskTrustUserCerts) for this.

#### Trust OTA

To replace `clearotacerts.zip` we need magisk module with our certificate.
Copy `ota.crt` to `otacerts/ota.crt`.

Execute the script and install the resulting module on your device.
```bash
python3 build.py
```

IMPORTANT!!! Be sure to flush the cache and storage of the `system update` application. Also freeze it in all profiles except the main one.

Congratulations. Now you can receive updates automatically.

## TODO:

- [x] web explorer
- [ ] update documentation
- [ ] ~~magisk module~~
