provision-node() {
  if [[ -f .node-version ]]; then
    REQUIRED_NODE_VERSION=$(cat .node-version)
  elif [[ -f .nvmrc ]]; then
    REQUIRED_NODE_VERSION=$(cat .nvmrc)
  else
    error "You don't seem to have a Node version set in your project."
    print-wrapped "\
You'll need to create a .node-version or .nvmrc file in your project before you
can run this script.
    "
    exit 1
  fi

  ensure-node-installed
  install-node-dependencies
}

ensure-node-installed() {
  if has-executable nodenv; then
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
We recommend using nodenv. You can find instructions to install it here:

    https://github.com/nodenv/nodenv#installation

Make sure to follow the instructions to configure your shell so that nodenv is
automatically loaded.

When you're done, open up a new terminal tab and re-run this script."
    exit 1
  fi
}

install-node-dependencies() {
  banner 'Installing Node dependencies'

  if [[ -f package-lock.json ]]; then
    npm install
  elif [[ -f yarn.lock ]]; then
    yarn install
  else
    error "Sorry, I'm not sure how to install your dependencies."
    print-wrapped "\
You'll need to create a package-lock.json or yarn.lock file in your project
before you can run this script.
    "
    exit 1
  fi
}
