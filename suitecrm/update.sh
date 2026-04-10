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
#  -V             Updates SuiteCRM to the latest version.
#  -h             Shows the help information of this script.
#
# Exit Codes (1X = Script; 2X = Docker; 3X = SuiteCRM):
#
#   0             Success (The update was successfully.)
#  10             There are invalid parameters.
#  11             The version was not specified.
#  12             Changing to SuiteCRM folder failed.
#  13             No parameter was specified.
#  20             The container is not known.
#  21             The container is not running.
#  22             The script could not be injected into the container.
#  30             The current version of SuiteCRM can not be updated.
#  31             No valid version specified.
#  32             The package for the specified version was not found.
# ------------------------------------------------------------------------

# set the latest version.
SUITECRM_LATEST=8.9.3

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
  printf "%-20s%-s\n" "  -V" "Updates SuiteCRM to the latest version ($SUITECRM_LATEST)."
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

# function to get the state whether the specified package exists.
package_exists() {
  local url
  url=$1
  code=$(curl -s -o /dev/null -w "%{http_code}" "${url}")
  [[ "$code" == "302" || "$code" == "200" ]]
}

# function to inject the script to the specified container.
inject_to_container() {
  local container
  container=$1
  docker cp ./update.sh "$container":/tmp/update.sh > /dev/null
  docker exec -it "$container" bash -c "chmod +x /tmp/update.sh"
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
    docker exec -it "$container" bash -c "/tmp/update.sh -v \"$version\""
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
if [[ ! "$cversion" =~ ^8\.[2-9]\.[0-9]$ ]]
then
  printf "This version can not be updated.\n"
  exit 30
fi

# check if the specified version for the package is a valid version.
if [[ ! "$version" =~ ^8\.[2-9]\.[0-9]$ ]]
then
  printf "No valid version specified.\n"
  exit 31
fi

# create the url for the package of the specified version.
url="https://github.com/SuiteCRM/SuiteCRM-Core/releases/download/v$version/SuiteCRM-$version.zip"

# check whether the package of the version exists.
if ! package_exists "$url"
then
  printf "The package for the specified version was not found.\n"
  exit 32
fi

# output some information about the parameters.
printf "\n\n"
printf "%-18s%-s\n" "Current Version:" "$cversion"
printf "%-18s%-s\n\n" "New Version:" "$version"
printf "Update for SuiteCRM started.\n\n"

# create the folder for upgrade data.
mkdir -p tmp/package/upgrade

# download the specified version.
printf "Download SuiteCRM %s ...\n" "$version"
curl -L -s -S "$url" -o "tmp/package/upgrade/SuiteCRM-$version.zip"
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
