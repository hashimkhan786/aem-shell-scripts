#!/bin/bash

# Default Variables
USER="admin"
PASSWORD="admin"
HOST="http://localhost:4502"

function usage
{
  echo "usage: ./aem-packager.sh [list|install|uninstall|download|upload|upload_install|build|delete] [groupname|localpath when uploading] [packagename]"
}

list ()
{
  echo "AVAILABLE PACKAGES:"
  curl -u $USER:$PASSWORD $HOST/crx/packmgr/service.jsp?cmd=ls > input.xml
  awk ' { gsub ( /\</, "" ) ; print } ' input.xml | awk '{sub(/\/.*/,""); print}' | cut -d\> -f2- | awk ' { gsub ( /\,/, "" ) ; print } ' > temp.csv
  awk ' NR>6 { line1 =$1 ; getline ; line2=$1 ; getline ; line3=$1 ; getline ; line4 =$1 ; getline ; line5=$1 ; getline ; line6=$1 ; getline ; line7 =$1 ; getline ; line8=$1$2$3$4 ; getline ; line9=$1 ; getline ; line10 =$1$2$3$4 ; getline ; line11 =$1 ; getline ; line12 =$1$2$3$4 ; getline ; line13 =$1 ; print line1 "," line2 "," line3 "," line4 "," line5 "," line6 "," line7 "," line8 "," line9 "," line10 "," line11 "," line12 "," line13 ;}' temp.csv > aem-packages.csv
  echo " Package List is Stored in the CSV File aem-packages.csv "
}

install_package ()
{
  echo "Insalling PACKAGE: "$1:$2

  if [ "$1" == "" -o "$2" == "" ]; then
    echo "Please add Group Name and Package name for the package "
    echo "e.g : ./aem-packager.sh install groupname packagename.zip"
    exit
  fi
  curl -u $USER:$PASSWORD -X POST --fail "$HOST/crx/packmgr/service/.json/etc/packages/$1/$2?cmd=install"
  echo ""
}

uninstall_package ()
{
  echo "UnInstalling PACKAGE: "$1:$2

  if [ "$1" == "" -o "$2" == "" ]; then
    echo "Please add Group Name and Package name for the package "
    echo "e.g : ./aem-packager.sh uninstall groupname packagename.zip"
    exit
  fi
  curl -u $USER:$PASSWORD -X POST --fail "$HOST/crx/packmgr/service/.json/etc/packages/$1/$2?cmd=uninstall"
  echo ""
}

upload_install ()
{
  echo "Upload and Install PACKAGE from : " $1
  if [ "$1" == ""]; then
    echo "Please add package path "
    echo "e.g : ./aem-packager.sh upload_install /Users/hakhan/Downloads/sample-2.0.zip "
    exit
  fi
  curl -u $USER:$PASSWORD -F file=@"$1" -F force=true -F install=true $HOST/crx/packmgr/service.jsp
  echo ""
}

upload ()
{
  echo "Upload and Not Install PACKAGE : " $1
  if [ "$1" == ""]; then
    echo "Please add package path "
    echo "e.g : ./aem-packager.sh upload /Users/hakhan/Downloads/sample-2.0.zip "
    exit
  fi
  curl -u $USER:$PASSWORD -F file=@"$1" -F force=true -F install=false $HOST/crx/packmgr/service.jsp
  echo ""
}

download ()
{
  echo "Downloading PACKAGE: "$1:$2 "to path : " $3

  if [ "$1" == "" -o "$2" == "" -o "$3" == "" ]; then
    echo "Please add Group Name and Package name and Destination path "
    echo "e.g : ./aem-packager.sh download groupname packagename.zip <path of folder>"
    exit
  fi
  curl -u $USER:$PASSWORD $HOST/etc/packages/$1/$2 > $3
  echo ""
}

build ()
{
  echo "Building PACKAGE: "$1:$2

  if [ "$1" == "" -o "$2" == "" ]; then
    echo "Please add Group Name and Package name "
    echo "e.g : ./aem-packager.sh build groupname packagename.zip"
    exit
  fi
  curl -u $USER:$PASSWORD -X POST --fail "$HOST/crx/packmgr/service/.json/etc/packages/$1/$2?cmd=build"
  echo ""
}

delete ()
{
  echo "Deleting PACKAGE: "$1:$2

  if [ "$1" == "" -o "$2" == "" ]; then
    echo "Please add Group Name and Package name "
    echo "e.g : ./aem-packager.sh delete groupname packagename.zip"
    exit
  fi
  curl -u $USER:$PASSWORD -X POST --fail "$HOST/crx/packmgr/service/.json/etc/packages/$1/$2?cmd=delete"
  echo ""
}

# Perform the actions
if [ "$1" = "list" ]; then
  list
elif [ "$1" = "install" ] ; then
  install_package $2 $3
elif [ "$1" = "upload_install" ] ; then
  upload_install $2
elif [ "$1" = "upload" ] ; then
  upload $2
elif [ "$1" = "download" ] ; then
  download
elif [ "$1" = "build" ] ; then
  build $2 $3
elif [ "$1" = "delete" ] ; then
  delete $2 $3
elif [ "$1" = "uninstall" ] ; then
  uninstall_package $2 $3
else
  usage
fi
