module RakeCommandFilter
  # default way to run rubocop and parse its output
  class RubocopCommandDefinition < RakeCommandDefinition
    # used for testing
    def self.failure_msg(offenses, files)
      "#{offenses} offenses in #{files} files"
    end

    # used for testing
    def self.success_msg(files)
      "#{files} files"
    end

    # Default parser for rubocop output.
    # @param id override this if you want to do something other than 'rake rubocop'
    def initialize(id = :rubocop)
      super(id, 'rubocop')

      # just use sensible defaults here.
      add_filter(:offenses_filter, /(\d+)\s+file.*,\s+(\d+)\s+offense/) do |matches|
        CommandDefinition.result_failure(RubocopCommandDefinition.failure_msg(matches[1], matches[0]))
      end

      add_filter(:no_offenses_filter, /(\d+)\s+file.*,\s+no\s+offenses/) do |matches|
        CommandDefinition.result_success(RubocopCommandDefinition.success_msg(matches[0]))
      end
    end
  end
end
