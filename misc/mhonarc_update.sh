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

days="$1"
shift

while [ "${1:-}" ]
do
  # Takes the name of a list and pulls posts from the plain text archives into mhonarc.

  list=$1
  shift

  export PATH=/bin:/usr/bin

  set +o pipefail
  count="$(find "/srv/lojban/plain/$list" -type f -mtime "-$days" | grep -v procmail.log | grep -v '\.zip$' | wc -l)"
  postdirs=$(find "/srv/lojban/plain/$list" -type f -mtime "-$days" -printf "%h\n" | grep -v '/rejected' | sort | uniq)
  set -o pipefail
  pdcount=$(echo "$postdirs" | wc -w)

  if [[ $count -gt 0 ]]
  then
    echo "New post count for $list is $count in $pdcount directories"
    for dir in $postdirs
    do
      # -mhpattern is from http://www.red-bean.com/doc/mhonarc/faq/usage.html#sepfiles
      /usr/bin/mhonarc -main -add -idxfname index.html -idxsize 100 -multipg -rcfile /usr/local/etc/mhonarc/indexer.mrc -outdir "/srv/lojban/web/$list" -mhpattern "^[0-9]" "$dir" 2>&1 | \
      sed 's/\.\.\.*/\./g' | \
      grep -v 'defined.%hash. is deprecated at' | \
      grep -v 'Maybe you should just omit the defined' | \
      grep -v 'This is MHonArc v' | \
      grep -v 'Reading database' | \
      grep -v 'Reading resource file' | \
      grep -v 'Adding message to /srv/lojban/web' | \
      grep -v 'No new messages' | \
      grep -v '^\s*$'
    done
  else
      echo "No new posts found for $list"
  fi
done

echo "Done with mhonarc_update run"
