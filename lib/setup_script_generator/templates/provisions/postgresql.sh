provision-postgresql() {
  ensure-postgresql-installed
  ensure-postgresql-running
}

ensure-postgresql-installed() {
  if ! has-executable psql; then
    banner 'Installing PostgreSQL'
    install postgresql
    install apt=libpq-dev rpm=postgresql-devel
  fi
}

ensure-postgresql-running() {
  if ! is-running postgres; then
    banner 'Starting PostgreSQL'
    start postgresql
  fi
}
