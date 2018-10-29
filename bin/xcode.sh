xcode::needs_installation() {
  xcode-select -p > /dev/null 2>&1
  [[ $? = 2 ]]
}

xcode::install() {
  echo "you will be prompted to install command line developer tools"
  echo 'please click the "Install" button'
  xcode-select --install > /dev/null 2>&1
}

xcode::wait_for_installation() {
  echo "waiting for command line developer tools installation to complete"
  while true; do
    xcode::needs_installation || break
    echo -n "."
    sleep 1
  done
  echo
}
