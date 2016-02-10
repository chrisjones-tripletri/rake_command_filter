require 'simplecov'
SimpleCov.start

require_relative './test_coverage'

RSpec.describe 'success spec' do
  
  it 'expects a success' do
    expect(TestCoverage.add(2, 3)).to eq(5)
  end
end