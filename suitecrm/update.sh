#!/bin/bash
# ------------------------------------------------------------------------
# This is a script to update an existing SuiteCRM installation
# on a Docker container (especially for bitnami/suitecrm).
#
# You can use these parameters to run the update script and
# also to specify additional information like the version.
#
#  -c <container> Run the script on the specified container.
#  -C             Run the script without a specified container.
#  -v <version>   The version of SuiteCRM which should be installed.
#  -V             Updated SuiteCRM to the latest version (8.4.1).
#  -h             Shows the help information of this script.
#
# Exit Codes (1X = Script; 2X = Docker; 3X = SuiteCRM):
#
#   0             Success (The update was successfully.)
#  10             There are invalid parameters.
#  11             The version was not specified.
#  12             Changing to SuiteCRM folder failed.
#  13             No paramerer was specified.
#  20             The container is not known.
#  21             The container is not running.
#  22             The script could not be injected into the container.
#  30             The current version of SuiteCRM can not be updated.
#  31             The specified version for update is not known.
# ------------------------------------------------------------------------

# set the latest version.
SUITECRM_LATEST=8.7.1

# function to output the help information to the terminal.
show_help() {
  printf "\n\n"
  printf "This is a script to update an existing SuiteCRM installation\n"
  printf "on a Docker container (especially for bitnami/suitecrm).\n\n"
  printf "You can use these parameters to run the update script and\n"
  printf "also to specify additional information like the version.\n\n"
  printf "%-20s%-s\n" "  -c <container>" "Run the script on the specified container."
  printf "%-20s%-s\n" "  -C" "Run the script without a specified container."
  printf "%-20s%-s\n" "  -v <version>" "The version of SuiteCRM which should be installed."
  printf "%-20s%-s\n" "  -V" "Updated SuiteCRM to the latest version (8.4.1)."
  printf "%-20s%-s\n" "  -h" "Shows the help information in the terminal."
  printf "\n\n"
}

# function to check whether a container with a specified ID or name exists.
container_exists() {
  local container id name
  container=$1
  id=$(docker ps --format="{{.ID}}" | grep -cxF "$container")
  name=$(docker ps --format="{{.Names}}" | grep -cxF "$container")
  [[ "$id" == "1" || "$name" == "1" ]]
}

# function to get the state of a specific container.
get_container_state() {
  docker ps --format="{{.ID}} {{.State}}" | awk -v container="$1" '{ if($1 == container) print $2 }'
}

# function to inject the script to the specified container.
inject_to_container() {
  local container
  container=$1
  docker cp ./update.sh "$container":/tmp/update.sh > /dev/null
  docker exec -it "$container" bash -c "chmod +x ./tmp/update.sh"
}

# show the help if there was no parameter specified.
if [[ "$#" == "0" ]]
then
  show_help
  exit 13
fi

# get the values from the parameters.
while getopts ":c:Vv:h" opt; do
  case $opt in
    c) container=$OPTARG;;
    v) version=$OPTARG;;
    V) version=$SUITECRM_LATEST;;
    h) show_help;exit 0;;
    \?) show_help;exit 10;;
  esac
done

# check whether a version is available.
if [[ -z ${version+x} ]]
then
  printf "A version has to be specified.\n"
  exit 11
fi

# check whether a container is available.
# the script tries to inject the script into the specified container.
if [[ -n ${container+x} ]]
then

  # check whether the container exists.
  if ! container_exists "$container"
  then
    printf "Container does not exist.\n"
    exit 20
  fi

  # check whether the container is running.
  if [[ ! $(get_container_state "$container") == "running" ]]
  then
    printf "Container is not running.\n"
    exit 21
  fi

  # inject the script to the specified container.
  if ! inject_to_container "$container"
  then
    printf "Script could not be injected into the container.\n"
    exit 22
  else
    docker exec -it "$container" bash -c "./tmp/update.sh -v $version"
    exit $?
  fi
fi

# ------------------------------------------------------------------------
# The actual update of SuiteCRM starts here.
# ------------------------------------------------------------------------

# switch to SuiteCRM folder and create the folder for upgrade data.
cd bitnami/suitecrm/ || exit 12

# get the current version of SuiteCRM.
cversion=$(cat VERSION)

# check if the current version of SuiteCRM can be updated.
if [[ ! $cversion =~ ^8\.[234567]\.[0-9]$ ]]
then
  printf "This version can not be updated.\n"
  exit 30
fi

# check whether the version is known.
case $version in
  8.2.0) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.2.0/SuiteCRM-8.2.0.zip;;
  8.2.1) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.2.1/SuiteCRM-8.2.1.zip;;
  8.2.2) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.2.2/SuiteCRM-8.2.2.zip;;
  8.2.3) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.2.3/SuiteCRM-8.2.3.zip;;
  8.2.4) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.2.4/SuiteCRM-8.2.4.zip;;
  8.3.0) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.3.0/SuiteCRM-8.3.0.zip;;
  8.3.1) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.3.1/SuiteCRM-8.3.1.zip;;
  8.4.0) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.4.0/SuiteCRM-8.4.0.zip;;
  8.4.1) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.4.1/SuiteCRM-8.4.1.zip;;
  8.4.2) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.4.2/SuiteCRM-8.4.2.zip;;
  8.5.0) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.5.0/SuiteCRM-8.5.0.zip;;
  8.5.1) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.5.1/SuiteCRM-8.5.1.zip;;
  8.6.0) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.6.0/SuiteCRM-8.6.0.zip;;
  8.6.1) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.6.1/SuiteCRM-8.6.1.zip;;
  8.6.2) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.6.2/SuiteCRM-8.6.2.zip;;
  8.7.0) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.7.0/SuiteCRM-8.7.0.zip;;
  8.7.1) url=https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.7.1/SuiteCRM-8.7.1.zip;;
  *) printf "No valid version specified.\n"; exit 31;;
esac

# output some information about the parameters.
printf "\n\n"
printf "%-18s%-s\n" "Current Version:" "$cversion"
printf "%-18s%-s\n\n" "New Version:" "$version"
printf "Update for SuiteCRM started.\n\n"

# create the folder for upgrade data.
mkdir -p tmp/package/upgrade

# download the specified version.
printf "Download SuiteCRM %s ...\n" "$version"
curl -L -s -S $url -o "tmp/package/upgrade/SuiteCRM-$version.zip"
printf "Dowloaded SuiteCRM %s.\n" "$version"

# to get the information about permissions you can use ls -l in public folder.
# User: daemon
# Group: root

# set permissions of the downloaded update archive.
chown daemon:root "tmp/package/upgrade/SuiteCRM-$version.zip"

# upgrade SuiteCRM to the specified version.
printf "Upgrade to SuiteCRM %s ...\n" "$version"
php ./bin/console suitecrm:app:upgrade -t "SuiteCRM-$version"
php ./bin/console suitecrm:app:upgrade-finalize -t "SuiteCRM-$version"
printf "Upgraded to SuiteCRM %s.\n" "$version"

# reset the permissions of the new SuiteCRM files.
printf "Set the file permissions ...\n"
find . -type d -not -perm 2755 -exec chmod 2755 {} \;
find . -type f -not -perm 0644 -exec chmod 0644 {} \;
find . ! -user daemon -exec chown daemon:root {} \;
printf "Done setting file permissions.\n"

# remove the folder for upgrade data.
rm -r tmp/package/upgrade/*

# the update is finished.
exit 0
