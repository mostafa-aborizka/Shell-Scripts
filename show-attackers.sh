#!/bin/bash

#This script displays the number of failed login attempts by IP address and location if it exceeds the limit.

LOG_FILE="${1}"

#Make sure a file is provided
if [[ ! -e "${LOG_FILE}" ]]
then 
   echo "Cannot open log file: ${LOG_FILE} " >&2
   exit 1
fi

echo 'Count,IP,Location'

#Loop through failed attempts
grep Failed syslog-sample | awk '{print $(NF - 3)}' | sort | uniq -c | while read COUNT IP
do 
 if [[ "${COUNT}" -gt 10 ]] 
 then 
    Location=$(geoiplookup ${IP} | awk -F ', ' '{print $2}')
    echo "${COUNT},${IP},${Location}"
 fi
done
exit 0
