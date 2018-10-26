#!/bin/bash

debug() {
  [[ $DEBUG == "true" ]]
}

source_libs() {
  local files=("key github")
  for file in $files; do
    temp=$(mktemp)
    curl -s -o $temp https://raw.githubusercontent.com/PeerStreet/aite-bootstrap/master/bin/${file}.sh
    source $temp
    rm $temp
  done
}

main() {
  debug && set -x
  source_libs

  key::set_for_github
  key::is_set && key::agent_add

  while true; do
    github::has_access && break
    key::fetch
    key::agent_add
    (key::default && key::unconfigure) || key::configure
    (key::needs_installation || github::needs_access) && github::install_key
  done

  key::agent_remove
}

main "$@"
