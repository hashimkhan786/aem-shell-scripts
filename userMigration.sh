#!/bin/bash

CREDS='admin:admin'
HOST=localhost
PORT=4502

QUERYURL=/bin/querybuilder.json
DATE=$(date +%Y%m%d%H%M%S)
PACKAGENAMEUSERS="users-${DATE}"
PACKAGENAMEGROUPS="groups-${DATE}"
PARAMSUSERS='path=/home/users&property=jcr%3aprimaryType&property.value=rep%3aUser&p.limit=-1&p.hits=full'
PARAMSGROUP='path=/home/groups&property=jcr%3aprimaryType&property.value=rep%3aGroup&p.limit=-1&p.hits=full'

usage ()
{
  echo "Usage: add type of Package you want to Export : user or group"
  echo "e.g : ./userMigration user"
  exit
}

statusCheck ()
{
  if [[ "$2" != "true" ]];then
    echo "$1 : Incorrect Curl command or Parameters . Please verify."
    exit
  fi
}

#Method to Grab the List of Users in the AEM instance.
listUsers ()
{
  echo "Getting List of Users:"
  OUTPUT=$(curl --write-out -s -u ${CREDS} "http://${HOST}:${PORT}${QUERYURL}?${PARAMSUSERS}")

  STATUS=$(jq '.success' <<< "${OUTPUT}")
  statusCheck "ListUsers" ${STATUS}
  addFilters "${OUTPUT}" $1

}

#Method to Grab the List of Groups in the AEM instance.
listGroups ()
{
  echo "Getting List of Groups:"
  OUTPUT=$(curl --write-out -s -u ${CREDS} "http://${HOST}:${PORT}${QUERYURL}?${PARAMSGROUP}")

  STATUS=$(jq '.success' <<< "${OUTPUT}")
  statusCheck "ListGroups" ${STATUS}
  addFilters "${OUTPUT}" $1

}

# Method to Create a package with the Given PackageName and Date Stamp.
createPackage ()
{
  echo "Creating Package:"
  OUTPUT=$(curl --write-out -s -u ${CREDS} \
  	"http://${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/users/$1.zip?cmd=create" \
  	-d packageName=$1 \
  	-d groupName=users)


  STATUS=$(jq '.success' <<< "${OUTPUT}")
  statusCheck "Create" ${STATUS}


}

# Method to add Filters to the created package.
addFilters ()
{
  OUTPUT=$1 | jq .
  RESULTS=$(jq '.results' <<< ${OUTPUT})
  STATUS=$(jq '.success' <<<  ${OUTPUT})
  USERPATHS=$(jq '.hits[]."jcr:path"' <<<  ${OUTPUT} | sed 's/"//g' )
  USERNAMES=$(jq '.hits[]."rep:principalName"' <<<  ${OUTPUT} | sed 's/"//g' )
  ARRAYUSERPATHS=( $USERPATHS )
  ARRAYUSERNAMES=( $USERNAMES )

  FILTER="["
  for ((i=0; i<${RESULTS}; i++)); do
    FILTER="${FILTER}{\"root\":\"${ARRAYUSERPATHS[${i}]}\", \"rules\":[{\"modifier\":\"exclude\",\"pattern\":\"${ARRAYUSERNAMES[${i}]}/.tokens\"}]}, "
  done
  FILTER="${FILTER:0:${#FILTER}-2}]"

  echo "Add Filter to Package"
  OUTPUT=$(curl --write-out -s -u ${CREDS} \
  	"http://${HOST}:${PORT}/crx/packmgr/update.jsp" \
  	-F "path=/etc/packages/users/$2.zip" \
  	-F "packageName=$2" \
  	-F "groupName=users" \
  	-F "_charset_=UTF-8" \
  	-F "filter=${FILTER}")

    STATUS=$(jq '.success' <<< "${OUTPUT}")
    statusCheck "Filter" ${STATUS}

}

# Method to build a package created above.
buildPackage ()
{
  echo "Build Package:"
  OUTPUT=$(curl --write-out -s -u ${CREDS} -X POST \
  	"http://${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/users/$1.zip?cmd=build")

  STATUS=$(jq '.success' <<< "${OUTPUT}")
  statusCheck "Build" ${STATUS}

}

# Perform the actions
if [ "$1" = "user" ]; then
  createPackage ${PACKAGENAMEUSERS}
  listUsers ${PACKAGENAMEUSERS}
  buildPackage ${PACKAGENAMEUSERS}
elif [ "$1" = "group" ] ; then

  createPackage ${PACKAGENAMEGROUPS}
  listGroups ${PACKAGENAMEGROUPS}
  buildPackage ${PACKAGENAMEGROUPS}
else
  usage
fi

