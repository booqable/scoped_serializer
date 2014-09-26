require 'coveralls'
Coveralls.wear!

require 'scoped_serializer'
require 'with_model'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
                                        :database => File.dirname(__FILE__) + '/leaser.sqlite3')

Dir['spec/support/**/*.rb'].each { |f| load f }
Dir['spec/fixtures/**/*.rb'].each { |f| load f }

RSpec.configure do |config|

  config.mock_with :rspec
  config.extend WithModel

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

end
