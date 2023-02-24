#!/bin/sh
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

# Autodelete of old versions.
find $SCRIPTPATH/ota -type f -mtime +90 -delete
find $SCRIPTPATH/ota -type d -empty -exec rmdir {} \;

# Checking for an docker image
if docker images | grep "avbroot" ; then
	echo "docker-avbroot installed"; 
else
	echo "Build docker-avbroot"; 
	docker build -t avbroot $SCRIPTPATH/docker
fi

# Directory initialization.
cd $SCRIPTPATH
mkdir -p ota
mkdir -p tmp
mkdir -p crt
cd -

# Search for a new version grapheneos.
if [ -n $ID ] ; then
	echo "Target name: $ID"; 
else
	echo "Target name: NULL";
	exit;
fi

TYPE=ota

TARGET=$(curl -s  https://grapheneos.org/releases \
	| grep -o -P '(?<=https://releases.grapheneos.org/).*?(?=>)' \
	| grep "$TYPE" \
	| grep "$ID" \
	| head -n 1)

echo "Last version: $TARGET"

if [ ! -f $SCRIPTPATH/ota/$TARGET ]; then
    curl -o $SCRIPTPATH/ota/$TARGET.original https://releases.grapheneos.org/$TARGET
else
	echo "There are no updates."; 
	exit
fi

# Magisk updates.
cd $SCRIPTPATH
if [ ! -f $SCRIPTPATH/ghrd ]; then
	echo "Download GHRD"; 
	GHRD="/zero88/gh-release-downloader"
	GHRD_VERSION=$(curl "https://github.com/$GHRD/releases/latest" -s -L -I -o /dev/null -w '%{url_effective}' | sed -n '{s@.*/@@; p}')
	GHRD_FILE="https://github.com/$GHRD/releases/download/$GHRD_VERSION/ghrd"
	curl -L "$GHRD_FILE" > "$SCRIPTPATH/ghrd" && chmod +x "$SCRIPTPATH/ghrd"
fi
cd -

cd $SCRIPTPATH/tmp
rm -f magisk.apk
../ghrd -x -a  'Magisk-.*.apk'  topjohnwu/Magisk
mv Magisk-*.apk magisk.apk
cd -

# Key generation
if [ ! -f $SCRIPTPATH/crt/avb_pkmd.bin ]; then
	echo "Certificates not found. Creation of certificates."; 
	docker run --rm  -it --entrypoint /init.sh -v $SCRIPTPATH/crt:/avbroot/crt avbroot
fi

# Image Patch
TAG=$(echo $TARGET | sed "s/\..*//")
docker run --rm -e TARGET="$TAG" -v $SCRIPTPATH/crt:/avbroot/crt -v $SCRIPTPATH/ota:/avbroot/ota -v $SCRIPTPATH/tmp:/avbroot/tmp avbroot
