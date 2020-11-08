provision-ruby() {
  USE_BUNDLER_1=0

  if [[ -f .tool-versions ]]; then
    REQUIRED_RUBY_VERSION=$(cat .tool-versions | grep '^ruby ' | head -n 1 | sed -Ee 's/^ruby (.+)$/\1/')
  elif [[ -f .ruby-version ]]; then
    REQUIRED_RUBY_VERSION=$(cat .ruby-version | head -n 1 | sed -Ee 's/^ruby-([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)$/\1/')
  fi

  if [[ -z $REQUIRED_RUBY_VERSION ]]; then
    error "Could not determine required Ruby version for this project."
    print-wrapped "\
Your project needs to include either a valid .tool-versions file with a 'ruby'
line or a valid .ruby-version file."
    exit 1
  fi

  ensure-ruby-development-libraries-installed
  ensure-ruby-installed

  if [[ -f Gemfile ]]; then
    ensure-project-ruby-dependencies-installed
  fi
}

ensure-ruby-development-libraries-installed() {
  local platform=$(determine-platform)

  if [[ $platform == "linux" ]]; then
    banner "Installing Ruby development libraries"
    install apt=ruby-dev rpm=ruby-devel
  fi
}

ensure-ruby-installed() {
  if has-executable asdf; then
    if ! (asdf current ruby | grep $REQUIRED_RUBY_VERSION'\>' &>/dev/null); then
      banner "Installing Ruby $REQUIRED_RUBY_VERSION with asdf"
      asdf install ruby $REQUIRED_RUBY_VERSION
    fi
  elif has-executable rbenv; then
    if ! (rbenv versions | grep $REQUIRED_RUBY_VERSION'\>' &>/dev/null); then
      banner "Installing Ruby $REQUIRED_RUBY_VERSION with rbenv"
      rbenv install --skip-existing "$REQUIRED_RUBY_VERSION"
    fi
  elif has-executable chruby-exec; then
    PREFIX='' source /usr/local/share/chruby/chruby.sh
    if ! (chruby '' | grep $REQUIRED_RUBY_VERSION'\>' &>/dev/null); then
      if has-executable install-ruby; then
        banner "Installing Ruby $REQUIRED_RUBY_VERSION with install-ruby"
        install-ruby "$REQUIRED_RUBY_VERSION"
      else
        error "Please use chruby to install Ruby $REQUIRED_RUBY_VERSION!"
      fi
    fi
  else
    error "You don't seem to have a Ruby manager installed."
    print-wrapped "\
We recommend using asdf. You can find instructions to install it here:

    https://asdf-vm.com

When you're done, close and re-open this terminal tab and re-run this script."
    exit 1
  fi
}

has-bundler() {
  has-executable bundle && bundle -v &>/dev/null
}

ensure-project-ruby-dependencies-installed() {
  banner 'Installing Ruby dependencies'

  if [[ $USE_BUNDLER_1 -eq 1 ]] && (! has-bundler || ! [[ $(bundle -v) =~ '^Bundler version 1\.' ]]); then
    gem install bundler:'~> 1.0'
  elif ! has-bundler; then
    gem install bundler
  fi

  bundle check || bundle install
}
