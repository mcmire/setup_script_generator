provision-elm() {
  local platform=$(determine-platform)

  if ! has-executable elm; then
    banner "Installing Elm"

    if [[ $platform == "mac" ]]; then
      install brew=elm
    else
      print-wrapped "\
It doesn't look like you have Elm installed.

Elm is easy to install on Mac, but requires more manual work on other platforms.
The best thing to do is to follow the installation instructions on the official
Elm guide:

    https://guide.elm-lang.org/install/elm.html
      "
      exit 1
    fi
  fi
}
