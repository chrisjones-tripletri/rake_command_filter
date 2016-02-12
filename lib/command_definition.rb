module RakeCommandFilter
  # Base class for commands that get executed, and their output filtered
  # rubocop:disable ClassLength
  class CommandDefinition
    attr_accessor :name
    attr_accessor :default_line_handling
    attr_accessor :filter

    # if a line doesn't match any of the patterns, then
    # @param name a name used to identify the command in ouput
    def initialize(name)
      @name = name
      @default_line_handling = LINE_HANDLING_HIDE_UNTIL_ERROR
      @filters = []
      @parameters = []
    end

    # add a new filter for output from this command
    # @param id [Symbol] an identifier for the filter within the command
    # @param pattern [RegEx] a regular expression which matches a pattern in a line
    # @yield yields back an array of matches from the pattern.   The block should return
    #   a CommmandDefinition#result_... variant
    def add_filter(id, pattern, &block)
      filter = LineFilter.new(id, pattern, block)
      @filters << filter
    end

    # add a parameter to be passed to the command when executed
    def add_parameter(param)
      @parameters << param
    end

    # override this method
    def execute
      return execute_system(@name)
    end

    # @return the most severe result from an array of results
    def self.find_worst_result(results)
      worst = []
      results.each do |result|
        if worst.empty? || worst.first.severity < result.severity
          worst = [result]
        elsif worst.first.severity == result.severity
          worst << result
        end
      end
      return worst
    end

    # @return a result indicating the command was successful
    def self.result_success(msg)
      create_result(RakeCommandFilter::MATCH_SUCCESS, msg)
    end

    # @return a result indicating the command failed.
    def self.result_failure(msg)
      create_result(RakeCommandFilter::MATCH_FAILURE, msg)
    end

    # @return a result indicating the command showed a warning.
    def self.result_warning(msg)
      create_result(RakeCommandFilter::MATCH_WARNING, msg)
    end

    # used to create a result with the specified result code and msg
    def self.create_result(result, msg)
      LineFilterResult.new(@name, result, msg)
    end

    private

    def execute_system(command)
      saved_lines = []
      results = []
      command_start = Time.now
      command = add_parameters(command)
      Open3.popen3(command) do |_stdin, stdout, stderr|
        process_output(stdout, results, saved_lines)
        process_output(stderr, results, saved_lines)
      end
      output_results(results, saved_lines, command_start)
      return results
    end

    def add_parameters(command)
      @parameters.each do |param|
        command << " #{param}"
      end
      return command
    end

    def process_output(stdout, results, saved_lines)
      until stdout.eof?
        line = stdout.readline
        match_line(line, results)
        saved_lines << line
      end
    end

    def output_results(results, saved_lines, command_start)
      results << create_default_result if results.empty?
      worst_results = CommandDefinition.find_worst_result(results)

      # if the lines
      output_lines(worst_results, saved_lines)
      unless @default_line_handling == RakeCommandFilter::LINE_HANDLING_HIDE_ALWAYS
        worst_results.each do |result|
          result.output(Time.now - command_start) unless result.result == RakeCommandFilter::MATCH_WARNING
        end
      end
    end

    def output_lines(worst_results, saved_lines)
      if worst_results[0].result != RakeCommandFilter::MATCH_SUCCESS &&
         @default_line_handling == RakeCommandFilter::LINE_HANDLING_HIDE_UNTIL_ERROR
        print_lines(saved_lines)
      end
    end

    def create_default_result
      CommandDefinition.result_failure('INTERNAL ERROR: no pattern matched a result in the output')
    end

    def match_line(line, results)
      result = process_filters(line)
      results << result if result
      return result
    end

    def process_filters(line)
      result = nil
      @filters.each do |filter|
        result = filter.match(line)

        # stop processing filters if we found a match.
        break if result
      end
      return result
    end

    def process_default_line(saved_lines, line)
      case @default_line_handling
      when RakeCommandFilter::LINE_HANDLING_HIDE_UNTIL_ERROR
        saved_lines << line
      when RakeCommandFilter::LINE_HANDLING_SHOW_ALWAYS
        puts line
      when RakeCommandFilter::LINE_HANDLING_HIDE_ALWAYS
        # do nothing
      end
    end

    def print_lines(lines)
      lines.each { |line| puts line }
    end
  end
end
