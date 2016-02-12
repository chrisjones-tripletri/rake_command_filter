module RakeCommandFilter
  # default way to run rubocop and parse its output
  class ScssLintCommandDefinition < CommandDefinition
    # for testing
    def self.warning_msg
      'One or more scss warnings, see above'
    end

    def self.error_msg
      'One or more scss errors, see above'
    end

    # Default parser for scss lint output.
    # @param id override this if you want to do something other than 'scss-lint'
    def initialize(id = 'scss-lint')
      super(id)
      # just use sensible defaults here.
      add_filter(:scss_error, /(.*\[(.)\].*)/) do |matches|
        kind = matches[1]
        if kind == 'W'
          result_warning(ScssLintCommandDefinition.warning_msg)
        else
          result_failure(ScssLintCommandDefinition.error_msg)
        end
      end
    end

    protected

    def create_default_result
      result_success('No errors.')
    end
  end
end
