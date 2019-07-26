provision-ruby() {
  if [[ -f .ruby-version ]]; then
    REQUIRED_RUBY_VERSION=$(cat .ruby-version)
  else
    error "You don't seem to have a Ruby version set in your project."
    print-wrapped "\
You'll need to create a .ruby-version file in your project before you can run
this script.
    "
    exit 1
  fi

  install-ruby-development-library
  ensure-ruby-installed
  install-ruby-dependencies
}

install-ruby-development-library() {
  install apt=ruby-dev rpm=ruby-devel
}

ensure-ruby-installed() {
  if has-executable rbenv; then
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
        error "Please install Ruby $REQUIRED_RUBY_VERSION"
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
We recommend using rbenv. You can find instructions to install it here:

    https://github.com/rbenv/rbenv#installation

Make sure to follow the instructions to configure your shell so that rbenv is
automatically loaded.

When you're done, open up a new terminal tab and re-run this script."
    exit 1
  fi
}

install-ruby-dependencies() {
  banner 'Installing Ruby dependencies'
  gem install bundler -v '~> 1.0' --conservative
  bundle check || bundle install
}
