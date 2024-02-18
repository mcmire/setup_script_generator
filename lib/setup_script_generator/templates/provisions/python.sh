REQUIRED_PYTHON_VERSION=

provision-python() {
  if [[ -f .tool-versions ]]; then
    REQUIRED_PYTHON_VERSION=$(cat .tool-versions | grep '^python ' | head -n 1 | sed -Ee 's/^python (.+)$/\1/')
  elif [[ -f .python-version ]]; then
    REQUIRED_PYTHON_VERSION=$(cat .python-version | head -n 1 | sed -Ee 's/^python-([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)$/\1/')
  fi

  if [[ -z $REQUIRED_PYTHON_VERSION ]]; then
    error "Could not determine required Python version for this project."
    print-wrapped "\
Your project needs to include either a valid .tool-versions file with a 'python'
line or a valid .python-version file."
    exit 1
  fi

  ensure-python-installed
  ensure-pipx-installed

  if [[ -f pyproject.toml ]] || [[ -f requirements.txt ]]; then
    ensure-project-python-dependencies-installed
  fi
}

ensure-python-installed() {
  if has-executable asdf; then
    if ! (asdf current python | grep $REQUIRED_PYTHON_VERSION'\>' &>/dev/null); then
      banner "Installing Python $REQUIRED_PYTHON_VERSION with asdf"
      asdf install python $REQUIRED_PYTHON_VERSION
    fi
  elif has-executable pyenv; then
    if ! (pyenv versions | grep $REQUIRED_PYTHON_VERSION'\>' &>/dev/null); then
      banner "Installing Python $REQUIRED_PYTHON_VERSION with pyenv"
      pyenv install --skip-existing "$REQUIRED_PYTHON_VERSION"
    fi
  else
    error "You don't seem to have a Python manager installed."
    print-wrapped "\
We recommend using asdf. You can find instructions to install it here:

    https://asdf-vm.com

When you're done, close and re-open this terminal tab and re-run this script."
    exit 1
  fi
}

ensure-pipx-installed() {
  if ! has-executable pipx; then
    banner "Installing pipx"
    pip install --user pipx
  fi
}

ensure-project-python-dependencies-installed() {
  banner 'Installing Python dependencies'

  if [[ -f pyproject.toml ]]; then
    if ! has-executable poetry; then
      banner "Installing Poetry"
      pipx install poetry
    fi

    poetry install
  else
    warning "Did not detect a way to install Python dependencies."
  fi
}
