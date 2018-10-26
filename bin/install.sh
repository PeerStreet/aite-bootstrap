#!/bin/bash

source "${BASH_SOURCE%/*}/key.sh"
source "${BASH_SOURCE%/*}/github.sh"

debug() {
  [[ $DEBUG == "true" ]]
}

main() {
  debug && set -x

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
