require 'diff'

RSpec.configure do |config|
  config.mock_with :rspec
  config.alias_it_should_behave_like_to :it_should_correctly, 'it should correctly'
end
