module RakeCommandFilter
  # default way to run rubocop and parse its output
  class RSpecCommandDefinition < RakeCommandDefinition
    # for testing
    def self.failure_msg(failures)
      "#{failures} failed"
    end

    # for testing
    def self.success_msg(success)
      "#{success} passed"
    end

    # for testing
    def self.coverage_msg(percent)
      "#{percent} test coverage"
    end

    # Default parser for rspec output.
    # @param id override this if you want to do something other than 'rake spec'
    def initialize(coverage_threshold = 95, id = :spec)
      super(id, 'rspec')
      # just use sensible defaults here.
      add_rspec
      add_simplecov(coverage_threshold)
    end

    private

    def add_rspec
      add_filter(:rspec_filter, /(\d+)\s+example[s]?,\s+(\d+)\s+failure/) do |matches|
        failures = matches[1].to_i
        if failures > 0
          CommandDefinition.result_failure(RSpecCommandDefinition.failure_msg(failures))
        else
          CommandDefinition.result_success(RSpecCommandDefinition.success_msg(matches[0]))
        end
      end
    end

    def add_simplecov(coverage_threshold)
      add_filter(:simplecov_filter, /Coverage.+LOC\s+\((\d+[\.]?\d+)%/) do |matches|
        percent = matches[0].to_f
        msg = RSpecCommandDefinition.coverage_msg(percent)
        if percent >= coverage_threshold
          CommandDefinition.result_success(msg)
        else
          CommandDefinition.result_failure(msg)
        end
      end
    end
  end
end
