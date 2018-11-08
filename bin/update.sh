#!/bin/bash

debug() {
  [[ $DEBUG == "true" ]]
}

source_remote() {
  temp=$(mktemp)
  curl -s -o $temp https://raw.githubusercontent.com/PeerStreet/kue-bootstrap/master/bin/${1}.sh
  source $temp
  rm $temp
}

main() {
  debug && set -x
  source_remote "kue"

  kue::update
}

main "$@"
