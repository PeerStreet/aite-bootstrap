#!/bin/bash

function check_github_access {
  echo -n "checking github access..."
  ssh -o StrictHostKeyChecking=false -T git@github.com > /dev/null 2>&1
  test $? -eq 1
}

if check_github_access; then
  echo "ok"
else
  echo "nope"
  echo "SSH access to github required, you may:"
  echo "(G)enerate new keypair"
  echo "(U)se existing keypair"
  while true; do
    read gu
    case $gu in
      [Gg]*)
        while true; do
          read -p "Enter file in which to save the key (id_rsa): " keyfile
          : ${keyfile:=id_rsa}
          keyfile=${HOME}/.ssh/${keyfile}
          if ssh-keygen -f $keyfile; then
            break
          fi
        done
        break;;
      [Uu]*)
        while true; do
          read -p "Enter file in which to save the key (id_rsa): " keyfile
          : ${keyfile:=id_rsa}
          keyfile=${HOME}/.ssh/${keyfile}
          if ssh-keygen -q -N '' -f $keyfile; then
            break
          fi
        done
        echo "Paste your private key in PEM format:"
        stty -echo
        key=''
        save_ifs=$IFS
        IFS=''
        while read -d '' -n 1 c; do
          if [[ $c = '\x00' ]]; then
            key+="\n"
          else
            key+="$c"
          fi
          [[ $key == *"-----END RSA PRIVATE KEY-----" ]] && break
        done
        echo $key > $keyfile
        ssh-keygen -y -f $keyfile > ${keyfile}.pub
        IFS=$save_ifs
        stty echo
        if check_github_access; then
          echo "existing key already installed on github"
        else
          echo "existing key not installed on github"
        fi
        break;;
      *)
        echo "Please answer 'G' or 'U'";;
    esac
  done
fi
