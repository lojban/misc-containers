#!/bin/bash

echo -e "\n\nThis destroys your current DKIM keys.  It's fine.\n\n"
cd misc/ || exit 1
openssl genrsa -out dkim.private 2048
openssl rsa -in dkim.private -out dkim.public -pubout -outform PEM
echo -e "\n\nHere's your DKIM TXT record\n\n"
echo $(echo $(date -u +%Y%m%d%H%M && echo ._domainkey.lojban.org) | sed -e 's/[ ]//g' && echo $(echo ' TXT "v=DKIM1; p="' && echo $(grep 'PUBLIC KEY' -v dkim.public) | sed -e 's/[ ]//g' | fold -w200 | sed -e 's/\(.*\)/"\1"/g'))
