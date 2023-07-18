#!/bin/bash
# ------------------------------------------------------------------------
# This script is a collection of useful functions for Docker.
# ------------------------------------------------------------------------

# function to check whether a container with a specified ID or name exists.
container_exists() {
  local container
  container=$1
  id=$(docker ps --format="{{.ID}}" | grep -cxF "$container")
  name=$(docker ps --format="{{.Names}}" | grep -cxF "$container")
  [[ "$id" == "1" || "$name" == "1" ]]
}

# function to get the state of a specific container.
get_container_state() {
  docker ps --format="{{.ID}} {{.State}}" | awk -v container="$1" '{ if($1 == container) print $2 }'
}