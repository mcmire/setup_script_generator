provision-sqlite3() {
  ensure-sqlite3-installed
}

ensure-sqlite3-installed() {
  if ! has-executable sqlite3; then
    banner 'Installing SQLite 3'
    install sqlite3
    install apt=libsqlite3-dev rpm=sqlite-devel
  fi
}
