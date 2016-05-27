module OverallRequestTimes
  class Railtie < Rails::Railtie
    initializer "overall_request_times.configure_rails_initialization" do |app|
      app.middleware.use OverallRequestTimes::RailsMiddleware

      [:read, :write, :delete].each do |name|
        ActiveSupport::Notifications.subscribe("cache_#{name}.active_support") do |_name, start, ending, _id, _payload|
          OverallRequestTimes.add_duration(:cache, ending - start)
        end
      end
    end
  end
end
