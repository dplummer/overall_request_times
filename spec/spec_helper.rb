$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'overall_request_times'
require 'timecop'

RSpec.configure do |config|
  config.after(:each) do
    Timecop.return
  end
end
