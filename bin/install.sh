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
  source_remote "key"
  source_remote "github"
  source_remote "kue"
  source_remote "xcode"

  key::set_for_github
  key::is_set && key::agent_add

  while true; do
    github::has_access && break
    key::fetch
    key::agent_add
    (key::default && key::unconfigure) || key::configure
    (key::needs_installation || github::needs_access) && github::install_key
  done

  kue::bootstrap
  key::agent_remove
}

main "$@"
