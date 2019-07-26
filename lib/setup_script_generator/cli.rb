require "pathname"
require "optparse"
require "erb"

module SetupScriptGenerator
  class Cli
    TEMPLATES_DIR = Pathname.new("./templates").expand_path(__dir__)
    MAIN_TEMPLATE = TEMPLATES_DIR.join("main.sh.erb")
    PROVISIONS_DIR = TEMPLATES_DIR.join("provisions")

    def self.call(args, stdout, stderr)
      new(args, stdout, stderr).call
    end

    def initialize(args, stdout, stderr)
      @stdout = stdout
      @stderr = stderr
      @provision_names = []
      @overwrite_existing_file = false
      @dry_run = false

      parse_args!(args)
      validate_provision_names!

      if !dry_run?
        @output_file = determine_output_file!(args)
      end
    end

    def call
      if dry_run?
        stdout.puts generated_script
      elsif output_file.exist? && !overwrite_existing_file?
        stdout.puts "The file you're generating already exists."
        stdout.puts "If you want to overwrite it, re-run this script with --force."
        exit
      else
        output_file.parent.mkpath
        output_file.write(generated_script)
        output_file.chmod(0744)
        stdout.puts "File written to: #{output_file}"
      end
    end

    private

    attr_reader :stdout, :stderr, :provision_names, :output_file

    def overwrite_existing_file?
      @overwrite_existing_file
    end

    def dry_run?
      @dry_run
    end

    def parse_args!(args)
      option_parser.parse!(args)
    end

    def option_parser
      @_option_parser ||= OptionParser.new do |parser|
        parser.banner = "#{$0} [OPTIONS] OUTPUT_FILE"

        parser.on(
          "-p",
          "--provision [NAME]",
          String,
          "Inserts code into the setup script to provision a library or " +
          "package when the script runs."
        ) do |provision_name|
          provision_names << provision_name
        end

        parser.on("-f", "--force", "Overwrites the output file if it exists.") do
          @overwrite_existing_file = true
        end

        parser.on("-n", "--dry-run", "Outputs the generated script instead of writing to the file.") do
          @dry_run = true
        end

        parser.on("-l", "--list-provisions", "Lists the available provisions.") do
          stdout.puts "Here are the provisions you can specify with --provision NAME:"

          valid_provision_names.sort.each do |provision_name|
            stdout.puts "* #{provision_name}"
          end

          exit
        end

        parser.on("-h", "--help", "You're looking at it!") do
          puts parser
          exit
        end
      end
    end

    def determine_output_file!(args)
      if args.empty?
        error "Must provide an output file!"
        stderr.puts
        stderr.puts option_parser
        exit 1
      end

      Pathname.new(args.first).expand_path(ENV["PWD"])
    end

    def validate_provision_names!
      invalid_provision_name = provision_names.find do |provision_name|
        !valid_provision_names.include?(provision_name)
      end

      if invalid_provision_name
        error "Invalid provision: #{invalid_provision_name}"
        stderr.puts "Valid provisions are: #{valid_provision_names.join(', ')}"
        exit 2
      end
    end

    def valid_provision_names
      @_valid_provision_names ||= PROVISIONS_DIR.glob("*").map do |path|
        path.basename(".sh").to_s
      end
    end

    def generated_script
      @_generated_script ||= RenderFile.call(MAIN_TEMPLATE, provisions)
    end

    def provisions
      @_provisions ||= provision_names.map do |provision_name|
        Provision.new(provision_name, PROVISIONS_DIR)
      end
    end

    def error(message)
      stderr.puts "\e[31m[Error] #{message}\e[0m"
    end

    class Provision
      attr_reader :name

      def initialize(name, provisions_directory)
        @name = name
        @provisions_directory = provisions_directory
      end

      def code
        @_code ||= file.read
      end

      def valid?
        file.exist?
      end

      private

      attr_reader :provisions_directory

      def file
        @_file ||= provisions_directory.join("#{name}.sh")
      end
    end

    RenderFile = lambda do |file, provisions|
      ERB.new(file.read, trim_mode: '-').result(binding)
    end
  end
end
