provision-heroku() {
  if ! has-executable heroku; then
    banner 'Installing Heroku'
    install brew=heroku/brew/heroku heroku
  fi
}
