#!/bin/bash

# Error trapping from https://gist.github.com/oldratlee/902ad9a398affca37bfcfab64612e7d1
__error_trapper() {
  local parent_lineno="$1"
  local code="$2"
  local commands="$3"
  echo "error exit status $code, at file $0 on or near line $parent_lineno: $commands"
}
trap '__error_trapper "${LINENO}/${BASH_LINENO}" "$?" "$BASH_COMMAND"' ERR

set -euE -o pipefail
shopt -s failglob

for dir in /home/spdrata/misc-containers/shared_data/srv_lojban/plain/jbovlaste/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/jbovlaste-admin/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/llg-board/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/llg-members/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-beginners/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-de/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-es/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-fr/ /home/spdrata/misc-containers/shared_data/srv_lojban/plain/lojban-list/
do
    echo
    echo "*** $dir"
    cd $dir
    rm $(basename $dir).maildir.zip || true
    zip -q -r $(basename $dir).maildir.zip maildir/
done

echo "zipping up maildirs is complete"
