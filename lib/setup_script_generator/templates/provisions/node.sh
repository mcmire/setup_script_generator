provision-node() {
  if [[ -f .tool-versions ]]; then
    REQUIRED_NODE_VERSION=$(cat .tool-versions | grep '^nodejs ' | sed -Ee 's/^nodejs (.+)$/\1/')
  elif [[ -f .node-version ]]; then
    REQUIRED_NODE_VERSION=$(cat .node-version)
  elif [[ -f .nvmrc ]]; then
    REQUIRED_NODE_VERSION=$(cat .nvmrc)
  else
    error "You don't seem to have a Node version set in your project."
    print-wrapped "\
You'll need to create either a .tool-versions file or .nvmrc file in your
project before you can run this script."
    exit 1
  fi

  ensure-node-installed
  ensure-project-node-dependencies-installed
}

ensure-node-installed() {
  if has-executable asdf; then
    if ! (asdf current nodejs | grep $REQUIRED_NODE_VERSION'\>' &>/dev/null); then
      banner "Installing Node $REQUIRED_NODE_VERSION with asdf"
      asdf install nodejs $REQUIRED_NODE_VERSION
    fi
  elif has-executable nodenv; then
    if ! (nodenv versions | grep $REQUIRED_NODE_VERSION'\>' &>/dev/null); then
      banner "Installing Node $REQUIRED_NODE_VERSION with nodenv"
      nodenv install --skip-existing "$REQUIRED_NODE_VERSION"
    fi
  elif has-executable nvm; then
    if ! (nvm list | grep $required_node_version'\>' &>/dev/null); then
      banner "Installing node $required_node_version with nvm"
      nvm install $required_node_version
      nvm use $required_node_version
    fi
  else
    error "You don't seem to have a Node manager installed."
    print-wrapped "\
We recommend using asdf. You can find instructions to install it here:

    https://asdf-vm.com

When you're done, close and re-open this terminal tab and re-run this script."
    exit 1
  fi
}

ensure-project-node-dependencies-installed() {
  banner 'Installing Node dependencies'

  if [[ -f package-lock.json ]]; then
    npm install
  elif [[ -f yarn.lock ]]; then
    yarn install
  else
    error "Sorry, I'm not sure how to install your dependencies."
    print-wrapped "\
Are you missing a package.json? Have you run 'npm install' or 'yarn install'
yet?"
    exit 1
  fi
}
