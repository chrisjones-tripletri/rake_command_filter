module RakeCommandFilter
  # default way to run rubocop and parse its output
  class YardCommandDefinition < RakeCommandDefinition
    attr_accessor :threshold

    # for testing
    def self.percent_msg(percent)
      "#{percent} documented"
    end

    # for testing
    def self.warning_msg
      'One or more yard warnings, see above'
    end

    # Default parser for yard output.
    # @param threshold override this if you want to require less than 95% documentation
    # @param id override this if you want to do something other than 'rake spec'
    def initialize(threshold = 95, id = :yard)
      super(id, 'yard')
      # just use sensible defaults here.
      add_filter(:yard_percentage, /(\d+.?\d+)%\s+document/) do |matches|
        percent = matches[0].to_f
        msg = YardCommandDefinition.percent_msg(percent)
        (percent >= threshold) ? result_success(msg) : result_failure(msg)
      end
      add_filter(:yard_warning, /\[warn\]:(.*)/) do |_matches|
        result_warning(YardCommandDefinition.warning_msg)
      end
    end
  end
end
