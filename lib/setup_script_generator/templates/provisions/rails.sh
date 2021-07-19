provision-rails() {
  banner "Preparing database; removing old logs and tempfiles"
  bin/rails db:prepare log:clear tmp:clear

  banner "Restarting application server"
  bin/rails restart
}
