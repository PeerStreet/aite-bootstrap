kue::bootstrap() {
  xcode::needs_installation && xcode::install && xcode::wait_for_installation
  kue::clone
  kue::install
  kue::cleanup
}

kue::install() {
  kue/bin/install.sh
}

kue::update() {
  kue::clone
  kue::install
  kue::cleanup
}

kue::cleanup() {
  rm -fr $kue_temp
}

kue::clone() {
  kue::set_temp
  git clone git@github.com:PeerStreet/kue.git > /dev/null 2>&1
}

kue::set_temp() {
  kue_temp=$(mktemp -d)
  cd $kue_temp
}
