#!/bin/sh

cd /avbroot

mkdir -p ota/$TARGET

cp crt/avb_pkmd.bin ota/$TARGET/avb_pkmd.bin

python3 avbroot.py \
patch \
--input ota/$TARGET.zip.original \
--output ota/$TARGET.zip \
--privkey-avb crt/avb.key \
--privkey-ota crt/ota.key \
--cert-ota crt/ota.crt \
--magisk tmp/magisk.apk < crt/key.txt

python3 avbroot.py \
extract \
--input ota/$TARGET.zip \
--directory ota/$TARGET

python3 clearotacerts/build.py
cp clearotacerts/dist/clearotacerts-*.zip ota/$TARGET/clearotacerts.zip