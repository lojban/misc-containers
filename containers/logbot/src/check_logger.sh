#!/bin/bash

exec 2>&1

# set -x

# Cron's path tends to suck
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

ok=1

cd /tmp

if ! pgrep -f lojban_logger.pl >/dev/null 2>&1
then
  echo "No lojban_logger.pl process found."
  ok=""
fi

count="$(find /srv/lojban/irclogs/ -type f -mtime -1 -ls | grep -vP '(all_logs.txt|irclogs.zip)' | wc -l)"
if [ "$count" -lt 1 ]
then
  echo "Found only $count files in /srv/lojban/irclogs/ updated in the last day; not enough."
  ok=""
fi

OLDIFS="$IFS"
if [ ! "$ok" ]
then
  IFS=''
  text="

On $(uname -a)

Either there seems to be no lojban_logger.pl process, or there is no
recent activity in /srv/lojban/irclogs/

"

  echo $text

  echo $text | mailx -v -s "Lojban Logger Broken?" webmaster@lojban.org

  IFS="$OLDIFS"
fi

# Regardless, update the mega files
cd /srv/lojban/irclogs

rm irclogs.zip all_logs.txt

touch all_logs.txt

# set +x
# Print out the directory of all files (that is: print all dirs with actual files in them)
for dir in $(find jbosnu/ lojban/ -type f -printf "%h\n" | sort -d | uniq)
do
  cat $(find $dir/ -type f | sort -d) >>/srv/lojban/irclogs/all_logs.txt.new
done
# set -x

cat /srv/lojban/irclogs/all_logs.txt.new | grep -av '^\*' | grep -av '^<[^.]*.freenode.net> ' >/srv/lojban/irclogs/all_logs.txt
rm /srv/lojban/irclogs/all_logs.txt.new
zip irclogs.zip all_logs.txt | grep -v 'adding: all_logs.txt'
