# grapheneos-magisk

A small project implementing an update server for `GrapheneOS` with support for `Magisk`. Based on `avbroot`.

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
```
docker curl jq bash
```

The first start is carried out manually. Certificates are created.
```bash
ID=panther ./auto.sh
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

- [ ] Rebuild mobile [app](https://github.com/GrapheneOS/platform_packages_apps_Updater)

## TODO:

- [ ] web file viewer
- [ ] update documentation
