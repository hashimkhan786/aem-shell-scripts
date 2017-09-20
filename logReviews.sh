#!/bin/bash

LOG_FOLDER=/Users/hakhan/Documents/Work/AEMInstances/AEM6.1/crx-quickstart/logs

if [ "$1" == "" -o "$2" == "" ]; then
  echo "1. usage: add type of logfile to be reviewed : error or access or request"
  echo "2. usage: add regex to be used for the log file"
  echo "e.g : ./logReviewScript error error.log*"
  exit
fi

# Checks if the server is an Author or Publisher. This is not used here, but you can use this in future.
#PUB_OR_AUTH=`cat /etc/sysconfig/cq5 | grep -i R_AUTHOR`
#
#if [ $PUB_OR_AUTH == "R_AUTHOR=1" ]; then
# AEM_TYPE='author'
# cd /mnt/crx/author/crx-quickstart/logs
#else
# AEM_TYPE='publish'
# cd /mnt/crx/publish/crx-quickstart/logs
#fi

cd $LOG_FOLDER

echo "Loading..."
if [ "$1" == "error" ]; then
  grep "*WARN*" $2 | awk '{print $1 " , " $3 " , " $5 " , " substr($0,index($0,$6))}'| sort | uniq -c | sort -nr > warnLogReview.csv
  grep "*ERROR*" $2 | awk '{print $1 " , " $3 " , " $5 " , " substr($0,index($0,$6))}'| sort | uniq -c | sort -nr > errorLogReview.csv
  echo "Completed Error/ Warning Log Review for files :: " $2
elif [ "$1" == "access" ]; then
  awk '{print $5 " , " $6 "," $8 ","$7 "," $9 "," $10 "," $12}' access.log | sort | uniq -c | sort -nr > accessLogReview.csv
  echo "Completed Access Log Review for files :: " $2
elif [ "$1" == "request" ]; then
  awk '{id=$3 ;method=$5 ; path=$6 ; getline ; id2=$3; status=$5; type=$6; time=$7 ; print id "," method "," path "," "\n" id2 "," status "," type "," time ;}' $2 | awk ' { gsub ( /\[/, "" ) ; print } ' | awk ' { gsub ( /\]/, "" ) ; print } ' | sort -g > tempFile.csv
  awk -F "," 's != $1 || NR ==1{s=$1;if(p){print p};p=$0;next} {sub($1,"",$0);p=p""$0;}END{print p}' tempFile.csv > requestLogReview.csv
  echo "Completed Request Log Review for files :: " $2
fi
