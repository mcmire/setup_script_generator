require "pathname"
require "optparse"
require "erb"

require_relative "version"

module SetupScriptGenerator
  class Cli
    TEMPLATES_DIR = Pathname.new("./templates").expand_path(__dir__)
    PROVISIONS_DIR = TEMPLATES_DIR.join("provisions")
    SKELETON_TEMPLATE_PATH = TEMPLATES_DIR.join("skeleton.sh.erb")
    CUSTOMIZABLE_SECTION_PATH = TEMPLATES_DIR.join("customizable-section.sh")
    NON_CUSTOMIZABLE_SECTION_PATH = TEMPLATES_DIR.join("non-customizable-section.sh.erb")
    NON_CUSTOMIZABLE_SECTION_MARKER = <<-MARKER.strip
### DON'T MODIFY ANYTHING BELOW THIS LINE! #####################################
    MARKER

    def self.call(args, stdout, stderr)
      new(args, stdout, stderr).call
    end

    def initialize(args, stdout, stderr)
      @args = args
      @stdout = stdout
      @stderr = stderr

      @provision_names = []
      @dry_run = false
    end

    def call
      parse_args!(args)
      validate_provision_names!

      if dry_run?
        stdout.puts generated_content
      else
        output_file.parent.mkpath
        output_file.write(generated_content)
        output_file.chmod(0744)
        stdout.puts "File written to: #{output_file}"
      end
    end

    private

    attr_reader :args, :stdout, :stderr, :provision_names

    def dry_run?
      @dry_run
    end

    def parse_args!(args)
      option_parser.parse!(args)

      if args.empty?
        error "Must provide an output file!"
        stderr.puts
        stderr.puts option_parser
        exit 1
      end
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

    def output_file
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

    def generated_content
      if output_file.exist?
        content = ""

        output_file.each_line do |line|
          if line == "#{NON_CUSTOMIZABLE_SECTION_MARKER}\n"
            content << non_customizable_section
            break
          else
            content << line
          end
        end

        content
      else
        skeleton
      end
    end

    def skeleton
      @_skeleton ||= RenderFile.call(
        SKELETON_TEMPLATE_PATH,
        customizable_section: customizable_section,
        non_customizable_section: non_customizable_section
      )
    end

    def customizable_section
      @_customizable_section ||= File.read(CUSTOMIZABLE_SECTION_PATH)
    end

    def non_customizable_section
      @_non_customizable_section ||= RenderFile.call(
        NON_CUSTOMIZABLE_SECTION_PATH,
        provisions: provisions,
        version: SetupScriptGenerator::VERSION
      )
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

    RenderFile = lambda do |file, context|
      ERB.new(file.read, trim_mode: '-').result_with_hash(context)
    end
  end
end
