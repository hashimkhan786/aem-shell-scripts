#!/bin/bash

if [ "$1" == "" -o "$2" == "" ]; then
  echo "usage: use 'ls' to list files, 'rm' to remove them for first parameter"
  echo "usage: add domain path in second  parameter"
  echo "e.g : ./clearCacheScript ls projectx"
  exit
elif [ "$1" == "ls" ]; then
  export cmd='find  -regex ".*\.\(html\|css\|jpg\|js\|gif\|png\|json\|zip\)"'
elif [ "$1" == "rm" ]; then
  export cmd='find  -regex ".*\.\(html\|css\|jpg\|js\|gif\|png\|json\|zip\)" -delete'
fi

echo $cmd

export dir="/mnt/var/www/etc/clientlibs/"$2
echo '*******Deleting files in' $dir
cd $dir;
eval $cmd;

export dir="/mnt/var/www/etc/designs/"$2
echo '*******Deleting files in' $dir
cd $dir;
eval $cmd;

export dir="/mnt/var/www/content/dam/"$2
echo '******Deleting files in' $dir
cd $dir;
eval $cmd;

export dir="/mnt/var/www/content/"$2
echo '******Deleting files in' $dir
cd $dir;
eval $cmd;
