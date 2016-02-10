require 'open3'
require 'rake'
require 'rake/tasklib'
require 'rake_command_filter/version'
require_relative './line_filter_result'
require_relative './line_filter'
require_relative './command_definition'
require_relative './rake_command_definition'
require_relative './rubocop_command_definition'
require_relative './rspec_command_definition'
require_relative './yard_command_definition'

# A rake task that filters the output of other rake tasks so you can see
# what you care about.
module RakeCommandFilter
  # Always hide the line, no matter what
  LINE_HANDLING_HIDE_ALWAYS      = :hide_always

  # Show the line only after an error pattern line has been matched
  LINE_HANDLING_HIDE_UNTIL_ERROR = :hide_until_error

  # Show the line
  LINE_HANDLING_SHOW_ALWAYS      = :show_always

  @@testing = false # rubocop:disable Style/ClassVars

  # set to true if we are in at test context
  def self.testing=(_val)
    @@testing = true # rubocop:disable Style/ClassVars
  end

  # @return true if we are in a test context.
  def self.testing?
    return @@testing
  end

  # Provides a custom rake task.
  #
  # require 'rake_command_filter'
  # RakeCommandFilter::RakeTask.new
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    attr_accessor :verbose
    attr_accessor :fail_on_error
    attr_accessor :patterns
    attr_accessor :formatters
    attr_accessor :requires
    attr_accessor :options

    # default rake task initializer
    def initialize(*args, &task_block)
      @name = args.shift || :filter_tasks
      @verbose = true
      @commands = []

      desc 'TODO: FILL THIS IN THE BLOCK WHERE YOU CREATE THE TASK'

      instance_eval(&task_block)
      task(name, *args) do |_, _task_args|
        RakeFileUtils.send(:verbose, verbose) do
          run_main_task(verbose)
        end
      end
    end

    # call this to run a {CommandDefinition} subclass
    # @param defin an instance of a command definition subclass
    # @yield in the block, you can modify the internal state of the command,
    #   using desc, add_filter, etc.
    def run_definition(defin, &block)
      command = defin
      defin.instance_eval(&block) if block
      add_command(command)
    end

    # run all the tasks that have been added via {#run_definition}.
    def run_main_task(verbose)
      run_tasks(verbose)
    end

    private

    def add_command(command)
      @commands << command
    end

    def run_tasks(_verbose)
      @commands.each(&:execute)
      return 1
    end
  end
end
