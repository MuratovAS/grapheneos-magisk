#!/bin/sh

cd /avbroot


python3 avbroot.py \
patch \
--input ota/$TARGET.zip.original \
--output ota/$TARGET.zip \
--privkey-avb crt/avb.key \
--privkey-ota crt/ota.key \
--cert-ota crt/ota.crt \
--magisk tmp/magisk.apk < crt/key.txt

if [ $EXTRACT = "1" ] ; then
	mkdir -p ota/$TARGET
	cp crt/avb_pkmd.bin ota/$TARGET/avb_pkmd.bin
	python3 avbroot.py \
	extract \
	--input ota/$TARGET.zip \
	--directory ota/$TARGET
fi

chown -R $UID_C:$GID_C ota
chmod -R 755 ota