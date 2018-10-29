aite::bootstrap() {
  xcode::needs_installation && xcode::install && xcode::wait_for_installation
  #aite::clone
  aite::install
  aite::cleanup
}

aite::install() {
  aite/bin/install.sh
}

aite::cleanup() {
  rm -fr $aite_temp
}

aite::clone() {
  aite::set_temp
  git clone git@github.com:PeerStreet/aite.git > /dev/null 2>&1
}

aite::set_temp() {
  aite_temp=$(mktemp -d)
  cd $aite_temp
}
