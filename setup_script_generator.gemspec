lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "setup_script_generator/version"

Gem::Specification.new do |spec|
  spec.name          = "setup_script_generator"
  spec.version       = SetupScriptGenerator::VERSION
  spec.authors       = ["Elliot Winkler"]
  spec.email         = ["elliot.winkler@gmail.com"]

  spec.summary       = %q{Generate setup scripts for your projects.}
  spec.homepage      = "https://github.com/mcmire/setup_script_generator"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/mcmire/setup_script_generator"
    spec.metadata["changelog_uri"] = "https://github.com/mcmire/setup_script_generator/tree/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
