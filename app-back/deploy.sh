#!/bin/bash
set -e

###################################################
##config
export repository=$2

##funtions
abort() {
  print_error "aborting..."
  exit
}

print() {
  echo "---INFO: " "$1"
}

print_error() {
  echo "---ERROR: " "$1"
}

load_env() {
  print "loading environment..."
  source ./env.sh
}

deploy() {
  load_env
  docker-compose up
}

build() {
  load_env
  docker-compose build
}

destroy() {
  load_env
  docker-compose down
}

clone() {
  print "moving to mnt folder"
  cd /mnt
  if [ ! -d "dockerfiles" ]; then
    git clone $repository
    cd dockerfiles
  else
    cd dockerfiles
    git pull --all
  fi
  cd app-back
}

validation() {
  if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root"
    abort
  fi

  if [ "$1" != "up" ]; then
    if [ "$1" != "build" ]; then
      if [ "$1" != "down" ]; then
        print_error "action ($1) invalid, allow 'build', 'up' or 'down'"
        abort
      fi
    fi
  fi

  if [ -z "$2" ]; then
    print_error "please specificate a repository"
    abort
  fi

}

process-action() {
  if [ "$1" = "up" ]; then
    print "deploying compose file"
    deploy
  elif [ "$1" = "build" ]; then
    print "building compose file"
    build
  elif [ "$1" = "down" ]; then
    print "downing compose file"
    build
  else
    print_error "action ($1) invalid, allow 'build', 'up' or 'down'"
  fi
}

#################################################

## validations
validation "$1" "$2"

print "Starting docker compose app-back..."
print "cloning repository"
clone

print "deploying compose file"
process-action "$1"