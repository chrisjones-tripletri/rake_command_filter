# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_command_filter/version'

Gem::Specification.new do |spec|
  spec.name          = 'rake_command_filter'
  spec.version       = RakeCommandFilter::VERSION
  spec.authors       = ['Chris Jones']
  spec.email         = ['chris@tripletriangle.com']

  spec.summary       = 'Runs several rake tasks or system commands, and filters their output for easy review'
  spec.description   = 'Runs several rake tasks or system commands, and filters their output for easy review'
  spec.homepage      = 'https://github.com/chrisjones-tripletri/rake_command_filter'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'colorize'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.37.0'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'codeclimate-test-reporter'
  
end
