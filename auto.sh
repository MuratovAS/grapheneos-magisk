#!/bin/sh
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

# Settings
if [ -v $ID ] ; then
	ID=panther
	CHANNEL=stable
	TYPE=ota_update
	echo "Target default: $ID-$CHANNEL ($TYPE)";
else
	echo "Target custom: $ID-$CHANNEL ($TYPE)"; 
fi

# Directory initialization.
mkdir -p $SCRIPTPATH/ota
mkdir -p $SCRIPTPATH/tmp
mkdir -p $SCRIPTPATH/crt
echo "Run: $(date)" > $SCRIPTPATH/ota/info

# Autodelete of old versions.
find $SCRIPTPATH/ota -type f -mtime +90 -delete
find $SCRIPTPATH/ota -type d -empty -exec rmdir {} \;

# Checking for an docker image
if docker images | grep "avbroot" ; then
	echo "Found avbroot (docker)"; 
else
	echo "Build avbroot (docker)"; 
	docker build --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" --build-arg UNAME="$(whoami)" -t avbroot $SCRIPTPATH/docker
fi

# Search for a new version grapheneos.
URL="https://releases.grapheneos.org"
VERSION=$(curl -s $URL/$ID-$CHANNEL | head -n1 | awk '{print $1;}')
TARGET="$ID-$TYPE-$VERSION"
echo "Last version: $TARGET"

# Download new version grapheneos.
cd $SCRIPTPATH/ota
if ! [ -f "$TARGET.zip.original" ]; then
    curl -o $TARGET.zip.original $URL/$TARGET.zip
    curl -o $ID-$CHANNEL $URL/$ID-$CHANNEL
else
	echo "There are no updates"; 
	exit
fi
cd -

# Magisk updates.
cd $SCRIPTPATH
if ! [ -f "$SCRIPTPATH/ghrd" ]; then
	echo "Download GHRD"; 
	GHRD="/zero88/gh-release-downloader"
	GHRD_VERSION=$(curl "https://github.com/$GHRD/releases/latest" -s -L -I -o /dev/null -w '%{url_effective}' | sed -n '{s@.*/@@; p}')
	GHRD_FILE="https://github.com/$GHRD/releases/download/$GHRD_VERSION/ghrd"
	curl -L "$GHRD_FILE" > "$SCRIPTPATH/ghrd" && chmod +x "$SCRIPTPATH/ghrd"
fi
cd -
cd $SCRIPTPATH/tmp
rm -f magisk.apk
$SCRIPTPATH/ghrd -x -a  'Magisk-.*.apk'  topjohnwu/Magisk
mv Magisk-*.apk magisk.apk
cd -

# Key generation
if ! [ -f "$SCRIPTPATH/crt/avb_pkmd.bin" ]; then
	echo "Creation certificates"; 
	docker run --rm -e UID_C="$(id -u)" -e GID_C="$(id -g)"  -it --entrypoint /init.sh -v $SCRIPTPATH/crt:/avbroot/crt avbroot
else
	echo "Found certificates"; 
fi

# Image Patch
docker run --rm -e UID_C="$(id -u)" -e GID_C="$(id -g)" -e TARGET="$TARGET" -v $SCRIPTPATH/crt:/avbroot/crt:ro -v $SCRIPTPATH/ota:/avbroot/ota -v $SCRIPTPATH/tmp:/avbroot/tmp:ro avbroot
