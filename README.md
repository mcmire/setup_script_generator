# Setup Script Generator

Every project needs a [setup script][setup-script]
to quickly ready new developers for contributing to the project.
However, a good setup script is time-consuming to write:

[setup-script]: https://thoughtbot.com/blog/shell-script-suggestions-for-speedy-setups

* The script must make sure that the proper version of your project's language is installed,
  taking into account the usage of version managers.
* The script must be idempotent,
  installing new requirements while skipping over existing ones.
* The script must provide friendly messages (successful or otherwise).
* The script must be quick to run.
* The script must be usable on multiple platforms.
* The script must be easy to read and maintain.

Given these constraints,
this project generates a setup script that you can place in your own project.
This script is implemented in Bash
so that it is is performant, portable, and maintainable.

## Usage

Currently, the generator is available through a Ruby gem.
You can install this gem by first installing Ruby, then by running:

```
gem install setup_script_generator
```

After installing the gem, navigate to your project.
You now have the `generate-setup` command
which will allow you to generate a setup script where you like.
A common location is `bin/setup`, so you could say:

    generate-setup bin/setup

Now open up this file in your editor.
By default, this script is fairly empty,
although it does offer a section at the top
to which you can add custom code:

``` bash
provision-project() {
  # ...
}
```

While it is perfectly fine to update this function,
you will probably find it more useful to run `generate-setup` with a set of *provisions*.
These extend your script with checks and installation steps
for languages, frameworks, or services on which your project relies.
For instance, if your project requires Ruby,
then you'd want to run:

```
generate-setup bin/setup --provision ruby
```

(Don't worry, if you've already run `generate-setup`,
you can re-run it at any point in the future
to add or remove provisions.)

You can also use more than one provision if that's what you need:

```
generate-setup bin/setup --provision ruby --provision node
```

And you can get a list of available provisions by running:

```
generate-setup --list-provisions
```

Finally, to see the full list of options, run:

```
generate-setup --help
```

## Development

Naturally, this project comes with its own setup script.
Simply run this command to get started:

```
bin/setup
```

## Author/License

Setup Script Generator is copyright © 2019-2020 Elliot Winkler
(<elliot.winkler@gmail.com>)
and is released under the [MIT license](LICENSE.txt).
