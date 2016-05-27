module OverallRequestTimes
  class Railtie < Rails::Railtie
    initializer "overall_request_times.configure_rails_initialization" do |app|
      app.middleware.use OverallRequestTimes::RailsMiddleware

      ActiveSupport::Notifications.subscribe(/cache_(read|write|delete).active_support/) do |_name, start, finish, _id, _payload|
        OverallRequestTimes.add_duration(:cache, finish - start)
      end
    end
  end
end
