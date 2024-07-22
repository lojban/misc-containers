#!/bin/bash

log="$1"

# Get all the ids of mails that appear to have failed
for id in $(grep ' ......-......-.. \*\* ' "$log" | grep -P "^($(date -d 'yesterday' +%Y-%m-%d)|$(date +%Y-%m-%d))" | grep -v 'Spam detection software, running on the system "stodi.digitalkingdom.org"' | awk '{ print $5 }' | sort | uniq)
do
  grep " $id " "$log"
  echo
  echo
done
