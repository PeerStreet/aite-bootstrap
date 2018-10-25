github::has_access() {
  ssh -o StrictHostKeyChecking=false -T git@github.com > /dev/null 2>&1
  [[ $? = 1 ]]
}

github::needs_access() {
  ssh -o StrictHostKeyChecking=false -T git@github.com > /dev/null 2>&1
  [[ $? != 1 ]]
}

github::install_key() {
  (key::has_public || key::write_public) && key::set_public
  github::set_username
  github::set_otp
  curl -u $github_username -H "X-GitHub-OTP: ${github_otp}" -H "Content-Type: application/json" -d "{\"title\":\"aite-bootstrap\",\"key\":\"${public_key}\"}" https://api.github.com/user/keys
}

github::set_username() {
  read -p "enter your github username: " github_username
}

github::set_otp() {
  read -p "enter your github 2FA token: " github_otp
}
