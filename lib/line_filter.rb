module RakeCommandFilter
  # method for filtering a single line of output from a command
  class LineFilter
    attr_accessor :id, :pattern

    # Do not call this directly, use {CommandDefinition#add_filter}
    def initialize(id, pattern, block)
      @id = id
      @pattern = pattern
      @block = block
    end

    # Called to determine if this filter matches a line.   If it
    # does, returns the result from the block defined with
    # {CommandDefinition#add_filter}.
    # @return [LineFilterResult] or nil if no match occurred
    def match(source)
      source.scan(@pattern) do |matches|
        return @block.call(matches)
      end
      return nil
    end
  end
end
