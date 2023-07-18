#!/bin/bash
#
# A collection of useful functions for Docker.
#
# function to check whether a container with the specified ID or name exists.
container_exists() {
  local container id name
  container=$1
  id=$(docker ps --all --format="{{.ID}}" | grep -cxF "$container")
  name=$(docker ps --all --format="{{.Names}}" | grep -cxF "$container")
  [[ "$id" == "1" || "$name" == "1" ]]
}

# function to get the state of a specific container.
get_container_state() {
  docker ps --all --format="{{.ID}} {{.State}}" | awk -v container="$1" '{ if($1 == container) print $2 }'
}

# function to get the state whether this server is a swarm manager.
is_swarm_manager() {
  local state
  state=$(docker info --format '{{.Swarm.ControlAvailable}}')
  [[ "$state" == "true" ]]
}