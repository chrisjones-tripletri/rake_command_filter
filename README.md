[![Gem Version](https://badge.fury.io/rb/rake_command_filter.svg)](https://badge.fury.io/rb/rake_command_filter)
[![Build Status](https://travis-ci.org/chrisjones-tripletri/rake_command_filter.svg?branch=master)](https://travis-ci.org/chrisjones-tripletri/rake_command_filter)
[![Code Climate](https://codeclimate.com/github/chrisjones-tripletri/rake_command_filter/badges/gpa.svg)](https://codeclimate.com/github/chrisjones-tripletri/rake_command_filter)
[![Test Coverage](https://codeclimate.com/github/chrisjones-tripletri/rake_command_filter/badges/coverage.svg)](https://codeclimate.com/github/chrisjones-tripletri/rake_command_filter/coverage)

# RakeCommandFilter

RakeCommandFilter allows you to execute multiple rake commands in subprocesses and filter
their output for easy review.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rake_command_filter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rake_command_filter

## Purpose

Prior to checking in, I wanted to run all my favored validation tools (rubocop, rspec with simplecov, and yard), 
and review simple output like this:

```
OK             rubocop                1.27s     15 files
OK             spec                   7.97s     11 passed
OK             spec                   7.97s     96.9 test coverage
OK             yard                   1.46s     100.0 documented
```

so that I did not need to dig through the results to determine if I was satisfied.   Only if they failed did I want to see detailed output from a given command.

RakeCommandFilter does this, and can be extended to process the output of other tools.

## Usage

Put this in your Rakefile, then run ```rake full_validation```.

```ruby
require 'rake_command_filter'

RakeCommandFilter::RakeTask.new(:full_validation) do
  desc 'Run full validation'
  run_definition(RakeCommandFilter::RubocopCommandDefinition.new) do
    add_parameter('app/assets/stylesheets')
  end
  run_definition(RakeCommandFilter::RubocopCommandDefinition.new)
  run_definition(RakeCommandFilter::RSpecCommandDefinition.new)
  run_definition(RakeCommandFilter::YardCommandDefinition.new)
end
```

If you setup a rake command like that above, you can use this as a git pre-commit hook:

```bash
#!/bin/bash                                                                                                                                        
rake full_validation
exit $?
```
in order to see the nice output whenever you commit.

## Customization

You can customize rake_command_filter to run and parse the output of other
commands by implementing your own CommandDefinition subclass.  You can also
alter an existing version in a block, as in this example from the tests:

```ruby
task = RakeCommandFilter::RakeTask.new(:test_warn) do
  desc 'My deployment task'
  run_definition(RakeCommandFilter::YardCommandDefinition.new) do
    add_parameter(' doc yard_warn.rb')
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chrisjones-tripletri/rake_command_filter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

