#!/bin/sh

cd /avbroot/crt

openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out avb.key
cp avb.key ota.key
openssl req -new -x509 -sha256 -key ota.key -out ota.crt -days 10000 -subj '/CN=OTA/'

cd /avbroot
python3 external/avb/avbtool.py \
	extract_public_key \
	--key crt/avb.key \
	--output crt/avb_pkmd.bin

cd /avbroot
read -p 'Password: ' passvar
printf '%s\n%s' "$passvar" "$passvar" > crt/key.txt