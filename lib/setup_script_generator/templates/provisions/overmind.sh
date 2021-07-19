provision-overmind() {
  if ! has-executable overmind; then
    banner "Installing Overmind"
    install tmux overmind
  fi
}
