#!/bin/sh

days="$1"
shift

while [ "$1" ]
do
  # Takes the name of a list and pulls posts from the plain text archives into mhonarc.

  list=$1
  shift

  export PATH=/bin:/usr/bin

  posts=$(find /srv/lojban/plain/$list -type f -mtime -$days | grep -v procmail.log)
  count=$(echo $posts | wc -w)
  postdirs=$(find /srv/lojban/plain/$list -type f -mtime -$days -printf "%h\n" | grep -v '/rejected' | sort | uniq)
  pdcount=$(echo $postdirs | wc -w)

  if [ $count -gt 0 ]
  then
    echo "Post count for $list is $count in $pdcount directories"
    for dir in $postdirs
    do
      # -mhpattern is from http://www.red-bean.com/doc/mhonarc/faq/usage.html#sepfiles
      /usr/bin/mhonarc -main -add -idxfname index.html -idxsize 100 -multipg -rcfile /usr/local/etc/mhonarc/indexer.mrc -outdir /srv/lojban/web/$list -mhpattern "^[0-9]" $dir 2>&1 | \
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
  fi
done
