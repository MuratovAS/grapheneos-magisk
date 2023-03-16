#!/bin/sh
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

# Settings
TYPE=ota_update
if [ -v $ID ] ; then
	ID=panther
fi
if [ -v $CHANNEL ] ; then
	CHANNEL=stable
fi
if [ -v $EXTRACT ] ; then
	EXTRACT=0
fi

echo "Target custom: $ID-$CHANNEL ($TYPE)"; 

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
if ! [ -f "$TARGET.zip" ]; then
    curl -o $TARGET.zip.original $URL/$TARGET.zip
    curl -o $ID-$CHANNEL $URL/$ID-$CHANNEL
else
	echo "There are no updates"; 
	exit
fi
cd -

# Magisk updates.
cd $SCRIPTPATH/tmp
curl -s https://api.github.com/repos/topjohnwu/Magisk/releases/latest | jq -r '.assets[] | select(.name | contains ("Magisk")) | .browser_download_url' | xargs curl -o magisk.apk -L
cd -

# Key generation
if ! [ -f "$SCRIPTPATH/crt/avb_pkmd.bin" ]; then
	echo "Creation certificates"; 
	docker run --rm -e UID_C="$(id -u)" -e GID_C="$(id -g)"  -it --entrypoint /init.sh -v $SCRIPTPATH/crt:/avbroot/crt avbroot
else
	echo "Found certificates"; 
fi

# Image Patch
docker run --rm -e UID_C="$(id -u)" -e EXTRACT=$EXTRACT -e GID_C="$(id -g)" -e TARGET="$TARGET" -v $SCRIPTPATH/crt:/avbroot/crt:ro -v $SCRIPTPATH/ota:/avbroot/ota -v $SCRIPTPATH/tmp:/avbroot/tmp:ro avbroot
rm $SCRIPTPATH/ota/$TARGET.zip.original