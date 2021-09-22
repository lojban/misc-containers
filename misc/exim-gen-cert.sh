#!/usr/bin/bash

# Stolen from /usr/libexec/exim-gen-cert on Fedora 44, significantly modified

. /etc/sysconfig/network

# Source exim configureation.
if [ -f /etc/sysconfig/exim ] ; then
        . /etc/sysconfig/exim
fi

USER=${USER:=exim}
GROUP=${GROUP:=exim}

if [ ! -f /etc/pki/tls/certs/exim.pem ] ; then
    umask 077
    echo -n $"Generating exim certificate: "
    cat << EOF | openssl req -new -x509 -days 365 -nodes \
                        -out /etc/pki/tls/certs/exim.pem \
                        -keyout /etc/pki/tls/private/exim.pem &>/dev/null
--
VA
FairFax
LLG
Lojban Infrastructure
mail.lojban.org
webmaster@lojban.org
EOF

    if [ $? -eq 0 ]; then
        echo success
        chown $USER:$GROUP /etc/pki/tls/{private,certs}/exim.pem
        chmod 600 /etc/pki/tls/{private,certs}/exim.pem
    else
        echo failure
    fi
echo
fi
