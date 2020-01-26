provision-bash() {
  if ! has-executable shellcheck; then
    banner "Installing shellcheck"
    install shellcheck
  fi
}
