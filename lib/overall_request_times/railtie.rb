module OverallRequestTimes
  class Railtie < Rails::Railtie
    initializer "overall_request_times.configure_rails_initialization" do |app|
      app.middleware.use OverallRequestTimes::RailsMiddleware
    end
  end
end
