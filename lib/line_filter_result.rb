require 'colorize'

module RakeCommandFilter
  # returned by line filter block when a command is successful.
  MATCH_SUCCESS = :success

  # returned by line filter block when a command fails.
  MATCH_FAILURE = :failure

  # return by a line filter to indicate a warning from the command
  MATCH_WARNING = :warning

  # returned when a line filter doesn't match the specified line.
  MATCH_NONE = :none

  # text used to indicate failure
  FAILED_TEXT = 'FAILED'.freeze

  # text used to indicate success
  OK_TEXT = 'OK'.freeze

  # sumarizes the result of filtering a single line of command output
  class LineFilterResult
    attr_accessor :name, :result, :message

    # Do not create this directly, use the result_... variants in
    # {CommandDefinition}
    def initialize(name, result, output)
      @name = name
      @result = result
      @message = output
    end

    # @return an integer where 0 == success and higher numbers imply more
    # serious failures.
    def severity
      case @result
      when MATCH_SUCCESS
        return 0
      when MATCH_WARNING
        return 1
      when MATCH_FAILURE
        return 2
      else
        raise ArgumentError, 'Unknown result'
      end
    end

    # Called to output the result to the console.
    # @param elapsed the time running the command so far
    # rubocop:disable MethodLength
    def output(elapsed)
      case @result
      when MATCH_SUCCESS
        color = :green
        header = 'OK'
      when MATCH_FAILURE
        color = :red
        header = 'FAIL'
      when MATCH_WARNING
        color = :light_red
        header = 'WARN'
      end
      header = header.ljust(12).colorize(color)
      str_elapsed = "#{elapsed.round(2)}s"
      name = @name.to_s[0..17]
      puts "#{header}   #{name.ljust(20)}   #{str_elapsed.ljust(9)} #{@message}"
    end
  end
end
