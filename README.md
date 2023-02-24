# grapheneos-magisk

A small project implementing an update server for `GrapheneOS` with support for `Magisk`. Based on `avbroot`.
How it works:
- Generate certificates (first run)
- Download the latest `OTA ROM` for the given device ID (scheduled)
- Download the latest version of Magisk
- Patching `rom`
- Extract `img`
- Publication

## Usage

Required dependencies:
```
docker curl
```

The first start is carried out manually. Certificates are created.
```bash
ID=panther ./auto.sh
```

Launch frontend
```bash
sudo docker-compose up -d
```

Search for new versions of grapheneos. Add a task to `crontab -e`
```bash
20		*/6		*		*		*	/path-to-file/grapheneos-magisk/auto.sh
```
