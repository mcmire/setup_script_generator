# Setup Script Generator

Every project needs a [setup script][setup-script]. This is an executable that a
new contributor to the project can run in order to quickly prepare his or her
machine for development.

[setup-script]: https://thoughtbot.com/blog/shell-script-suggestions-for-speedy-setups

The problem is that a good setup script is time-consuming to write:

* The script must be portable, which means handling installation of software
  using package managers on different platforms.
* The script must be snappy, which (along with the previous point) dictates the
  use of Bash.
* The script must make sure that the proper version of your project's
  implementation language is installed, and if said language has version
  managers (such as for Ruby or Node), the script must take them into account
  as well.
* The script must provide friendly errors if any checks fail.
  (Bonus points for colors and/or emoji.)
* The script must be idempotent, so that if changes to the development are
  made, the script can be run again, and any requirements that are already
  satisfied will be skipped, while new requirements will be installed.
* The script must be easy to read and maintain in the future.

Given this, this project provides a way to generate a setup script for your own
project, so that you can keep all of your teammates on the same page and offer
them a nice experience going forward.

## Installation

Currently, the generator is available through a Ruby gem. You can install this
gem by first installing Ruby, then running:

    gem install setup_script_generator

## Usage

After installing the gem, navigate to your project. Generally, setup scripts are
kept in `bin`, so to generate a script, run:

    generate-setup bin/setup

Now, by default, this won't do a whole lot. That's because a setup script is
much more useful with *provisions*, which add checks and steps for a particular
language, framework, or service. For instance, if your project requires Ruby,
then you'd want to say:

    generate-setup bin/setup --provision ruby

You can add more than one provision if that's what you need:

    generate-setup bin/setup --provision ruby --provision node

You can get a list of available provisions by running:

    generate-setup --list-provisions

And if you want to view the setup script before you generate it, you can tack
`--dry-run` to the end of the command. For instance:

    generate-setup bin/setup --provision ruby --dry-run

Finally, to see the full list of options, run:

    generate-setup --help

## Development

Naturally, this gem comes with its own setup script you can use to get started.
Just run:

    bin/setup

To release a new version, update `version.rb`, then run `rake release`.

## Author/License

setup_script_generator is copyright © 2019-2020 Elliot Winkler
(<elliot.winkler@gmail.com>).

Available under the [MIT license](LICENSE.txt).
