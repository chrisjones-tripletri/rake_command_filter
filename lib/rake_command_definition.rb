module RakeCommandFilter
  # command that runs a rake task
  class RakeCommandDefinition < CommandDefinition
    attr_accessor :test_command

    # @param name will invoke rake <name> to run
    #   the command
    def initialize(name, test_command)
      super(name)
      @test_command = test_command
    end

    # Executes a rake task in a subprocess, and
    # captures and parses the output using the
    # filters associated with this command
    def execute
      command = RakeCommandFilter.testing? ? test_command : "rake #{@name}"
      return execute_system(command)
    end
  end
end
