require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rake_command_filter'
RakeCommandFilter.testing = true

# never show any output from the tests, because it is really confusing to run
# test in rspec which are in turn displaying test result from rspec.
def create_command(cmd)
  cmd.default_line_handling = RakeCommandFilter::LINE_HANDLING_HIDE_ALWAYS
  return cmd
end
