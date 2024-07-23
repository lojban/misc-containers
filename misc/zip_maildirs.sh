#!/bin/bash

for dir in /home/spdrata/misc-containers/shared_data/srv_lojban/plain/jbovlaste/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/jbovlaste-admin/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/llg-board/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/llg-members/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-beginners/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-de/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-es/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-fr/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-list/
do
    cd $dir
    rm $(basename $dir).maildir.zip
    zip -r $(basename $dir).maildir.zip maildir/
done
