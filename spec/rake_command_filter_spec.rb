require 'spec_helper'

describe RakeCommandFilter do
  TESTCASE_FOLDER = './test_cases/'.freeze
  RUBOCOP_FOLDER = "#{TESTCASE_FOLDER}/rubocop".freeze
  YARD_FOLDER = "#{TESTCASE_FOLDER}/yard".freeze
  RSPEC_FOLDER = "#{TESTCASE_FOLDER}/rspec".freeze

  # rubocop:disable AbcSize
  def execute_result_message(rspec, command, expected, msg)
    results = command.execute
    rspec.expect(results.length).to be >= 1
    result = results[0]
    rspec.expect(result.result).to rspec.eq(expected)
    rspec.expect(result.message).to rspec.eq(msg)
    return results
  end

  it 'has a version number' do
    expect(RakeCommandFilter::VERSION).not_to be nil
  end

  it 'detects rubocop errors' do
    Dir.chdir("#{RUBOCOP_FOLDER}/fail") do
      command = create_command(RakeCommandFilter::RubocopCommandDefinition.new)
      command.add_parameter('--config ../rubocop.yml')
      execute_result_message(self,
                             command,
                             RakeCommandFilter::MATCH_FAILURE,
                             RakeCommandFilter::RubocopCommandDefinition.failure_msg(3, 1))
    end
  end

  it 'detects rubocop ok' do
    Dir.chdir("#{RUBOCOP_FOLDER}/ok") do
      command = create_command(RakeCommandFilter::RubocopCommandDefinition.new)
      command.add_parameter('--config ../rubocop.yml')
      execute_result_message(self,
                             command,
                             RakeCommandFilter::MATCH_SUCCESS,
                             RakeCommandFilter::RubocopCommandDefinition.success_msg(1))
    end
  end

  it 'detects yard failure' do
    Dir.chdir("#{YARD_FOLDER}/fail") do
      command = create_command(RakeCommandFilter::YardCommandDefinition.new)
      command.add_parameter(' doc yard_fail.rb')
      execute_result_message(self,
                             command,
                             RakeCommandFilter::MATCH_FAILURE,
                             RakeCommandFilter::YardCommandDefinition.percent_msg('25.0'))
    end
  end

  it 'detects yard ok' do
    Dir.chdir("#{YARD_FOLDER}/ok") do
      command = create_command(RakeCommandFilter::YardCommandDefinition.new)
      command.add_parameter(' doc yard_ok.rb')
      execute_result_message(self,
                             command,
                             RakeCommandFilter::MATCH_SUCCESS,
                             RakeCommandFilter::YardCommandDefinition.percent_msg('100.0'))
    end
  end

  it 'detects yard warning' do
    Dir.chdir("#{YARD_FOLDER}/warn") do
      command = create_command(RakeCommandFilter::YardCommandDefinition.new)
      command.add_parameter(' doc yard_warn.rb')
      execute_result_message(self,
                             command,
                             RakeCommandFilter::MATCH_WARNING,
                             RakeCommandFilter::YardCommandDefinition.warning_msg)
    end
  end

  it 'detects rspec failure' do
    Dir.chdir("#{RSPEC_FOLDER}/fail") do
      command = create_command(RakeCommandFilter::RSpecCommandDefinition.new)
      command.add_parameter(' fail_spec.rb')
      execute_result_message(self,
                             command,
                             RakeCommandFilter::MATCH_FAILURE,
                             RakeCommandFilter::RSpecCommandDefinition.failure_msg(1))
    end
  end

  it 'detects rspec success' do
    Dir.chdir("#{RSPEC_FOLDER}/ok") do
      command = create_command(RakeCommandFilter::RSpecCommandDefinition.new)
      command.add_parameter(' ok_spec.rb')
      results = execute_result_message(self,
                                       command,
                                       RakeCommandFilter::MATCH_SUCCESS,
                                       RakeCommandFilter::RSpecCommandDefinition.success_msg(1))

      expect(results.length).to eq(2)
      result = results[1]
      expect(result.result).to eq(RakeCommandFilter::MATCH_SUCCESS)
      expect(result.message).to eq(RakeCommandFilter::RSpecCommandDefinition.coverage_msg('100.0'))
    end
  end

  it 'runs multiple tasks' do
    task = RakeCommandFilter::RakeTask.new(:test_multiple) do
      desc 'My deployment task'
      run_definition(RakeCommandFilter::RubocopCommandDefinition.new) do
        add_parameter('--config ../rubocop.yml')
      end
    end
    Dir.chdir("#{RUBOCOP_FOLDER}/ok") do
      task.run_main_task(false)
    end
    Dir.chdir("#{RUBOCOP_FOLDER}/fail") do
      expect { task.run_main_task(false) }.to raise_error RakeCommandFilter::CommandFailedError
    end
  end

  it 'outputs a warning' do
    task = RakeCommandFilter::RakeTask.new(:test_warn) do
      desc 'My deployment task'
      run_definition(RakeCommandFilter::YardCommandDefinition.new) do
        add_parameter(' doc yard_warn.rb')
      end
    end
    Dir.chdir("#{YARD_FOLDER}/warn") do
      expect { task.run_main_task(false) }.to raise_error RakeCommandFilter::CommandFailedError
    end
  end

  it 'tests line-filter severity', focus: true do
    line_ok   = RakeCommandFilter::LineFilterResult.new(:test, RakeCommandFilter::MATCH_SUCCESS, nil)
    line_warn = RakeCommandFilter::LineFilterResult.new(:test, RakeCommandFilter::MATCH_WARNING, nil)
    line_fail = RakeCommandFilter::LineFilterResult.new(:test, RakeCommandFilter::MATCH_FAILURE, nil)
    expect(line_ok.severity).to eq(0)
    expect(line_warn.severity).to eq(1)
    expect(line_fail.severity).to eq(2)

    line_bad = RakeCommandFilter::LineFilterResult.new(:test, :no_such_result, nil)
    expect { line_bad.severity }.to raise_error(ArgumentError)
  end

  it 'fails intentionally' do
    expect(2).to eq(1)
  end
end
