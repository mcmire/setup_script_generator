REQUIRED_NODE_VERSION=

provision-node() {
  if [[ -f .tool-versions ]]; then
    REQUIRED_NODE_VERSION=$((cat .tool-versions | grep '^nodejs ' | sed -Ee 's/^nodejs (.+)$/\1/') || echo '')
  elif [[ -f .node-version ]]; then
    REQUIRED_NODE_VERSION=$(cat .node-version)
  elif [[ -f .nvmrc ]]; then
    REQUIRED_NODE_VERSION=$(cat .nvmrc)
  fi

  if [[ -z $REQUIRED_NODE_VERSION ]]; then
    error 'Could not determine required Node version for this project.'
    print-wrapped "\
Your project needs to include either a valid .tool-versions file with a 'nodejs'
line or a valid .node-version or .nvimrc file."
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
  if [[ -f package-lock.json ]]; then
    banner 'Installing Node dependencies'
    npm install
  elif [[ -f yarn.lock ]]; then
    if ! type yarn &>/dev/null || ! yarn --version &>/dev/null; then
      banner 'Installing Yarn 1'
      npm install -g yarn
    fi
    banner 'Installing Node dependencies'
    yarn install
  else
    error "Sorry, I'm not sure how to install your dependencies."
    print-wrapped "\
It doesn't look like you have a package-lock.json or yarn.lock in your project
yet. I'm not sure which package manager you plan on using, so you'll need to run
either \`npm install\` or \`yarn install\` once first. Additionally, if you want
to use Yarn 2, then now is the time to switch to that. Then you can re-run this
script."
    exit 1
  fi
}
