provision-ruby() {
  if [[ -f .tool-versions ]]; then
    REQUIRED_RUBY_VERSION=$(cat .tool-versions | grep '^ruby ' | sed -Ee 's/^ruby (.+)$/\1/')
  elif [[ -f .ruby-version ]]; then
    REQUIRED_RUBY_VERSION=$(cat .ruby-version)
  else
    error "You don't seem to have a Ruby version set in your project."
    print-wrapped "\
You'll need to create either a .tool-versions file or .ruby-version file in your
project before you can run this script."
    exit 1
  fi

  ensure-ruby-development-libraries-installed
  ensure-ruby-installed
  ensure-project-ruby-dependencies-installed
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
  elif has-executable rvm; then
    if ! (rvm list | grep $required_ruby_version'\>' &>/dev/null); then
      banner "Installing Ruby $required_ruby_version with rvm"
      rvm install $required_ruby_version
      rvm use $required_ruby_version
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

  if [[ $USE_BUNDLER_1 -eq 1 ]] && (! has-bundler || [[ $(bundle -v) =~ '^1\.' ]]); then
    gem install bundler -v '~> 1.0'
  elif ! has-bundler; then
    gem install bundler
  fi

  bundle check || bundle install
}
