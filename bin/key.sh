key::is_set() {
  [[ -n "$key" ]]
}

key::set() {
  read -p "enter file in which to save the key (id_rsa): " key
  : ${key:=id_rsa}
  key=${HOME}/.ssh/${key}
}

key::has_public() {
  [[ -f "${key}.pub" ]]
}

key::set_public() {
  public_key=$(cat "${key}.pub")
}

key::default() {
  [[ $key == *"/.ssh/id_rsa" ]]
}

key::unconfigure() {
  [[ -f ~/.ssh/config ]] && sed '/# begin aite-bootstrap config/,/# end aite-bootstrap config/d' ~/.ssh/config > ~/.ssh/config
}

key::configure() {
  key::unconfigure
  echo "# begin aite-bootstrap config" >> ~/.ssh/config
  echo "Host github.com" >> ~/.ssh/config
  echo "  IdentityFile ${key}" >> ~/.ssh/config
  echo "# end aite-bootstrap config" >> ~/.ssh/config
}

key::generate() {
  while true; do
    key::set
    ssh-keygen -q -f $key && break
  done
}

key::generate_stub() {
  while true; do
    key::set
    ssh-keygen -q -N '' -f $key && break
  done
}

key::read() {
  echo "paste your private key in PEM format:"
  stty -echo
  local pem=''
  local save_ifs=$IFS
  IFS=''
  while read -d '' -n 1 c; do
    if [[ $c = '\x00' ]]; then
      pem+="\n"
    else
      pem+="$c"
    fi
    [[ $pem == *"-----END RSA PRIVATE KEY-----" ]] && break
  done
  IFS=$save_ifs
  stty echo
  key::write_private "${pem}"
}

key::write_private() {
  local pem="${1}"
  echo "${pem}" > $key
}

key::write_public() {
  while true; do
    ssh-keygen -y -f $key > ${key}.pub && break
  done
}

key::select() {
  local keys=()
  for file in ${HOME}/.ssh/*; do
    if [[ $(stat -f "%OLp" $file) == "600" ]]; then
      keys+=($file)
    fi
  done
  if [[ ${keys[@]} ]]; then
    while true; do
      echo "Select a private key:"
      PS3=
      select key in "${keys[@]}"; do
        break
      done
      key::is_set && break
    done
  else
    echo "no private keys found"
  fi
}

key::needs_installation() {
  [[ $key_needs_installation == "true" ]]
}

key::agent_add() {
  while true; do
    ssh-add -q $key > /dev/null 2>&1 && break
  done
}

key::agent_remove() {
  ssh-add -q -d $key > /dev/null 2>&1
}

key::set_for_github() {
  for identityfile in $(ssh -G git@github.com | grep identityfile); do
    eval identityfile=$identityfile
    [[ -f $identityfile ]] && key=${identityfile} && break
  done
}

key::fetch() {
  while true; do
    echo "SSH access to github required, you may:"
    echo "(G)enerate new keypair"
    echo "(P)aste existing private key"
    echo "(U)se existing installed private key"
    while true; do
      read gpu
      case $gpu in
        [Gg]*)
          key::generate
          key_needs_installation=true
          break;;
        [Pp]*)
          key::generate_stub
          key::read
          break;;
        [Uu]*)
          key::select
          break;;
        *)
          echo "please answer 'G', 'P', or 'U'";;
      esac
    done
    key::is_set && break
  done
}
