require 'distinctio'
require 'active_record'

Bundler.require :development

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.configurations = YAML::load(File.read(File.dirname(__FILE__) + "/support/database.yml"))
ActiveRecord::Base.establish_connection(ENV["DB"] || "sqlite3")

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

ActiveRecord::Migrator.migrate(File.dirname(__FILE__) + "/support/migrate")

RSpec.configure do |config|
  config.mock_with :rspec
  config.alias_it_should_behave_like_to :it_should_correctly, 'it should correctly'
end
