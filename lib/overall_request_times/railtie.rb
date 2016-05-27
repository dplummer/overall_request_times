module OverallRequestTimes
  class Railtie < Rails::Railtie
    initializer "overall_request_times.configure_rails_initialization" do |app|
      app.middleware.use OverallRequestTimes::RailsMiddleware

      ActiveSupport::Notifications.subscribe(/cache_(read|write|delete).active_support/) do |name, start, finish, _id, payload|
        duration_in_seconds = finish - start
        if duration_in_seconds > 0.005
          Rails.logger.info "Cache operation took over 5ms: name:#{name} start:#{start.to_f} finish:#{finish.to_f} payload:#{payload.inspect}"
        end
        OverallRequestTimes.add_duration(:cache, duration_in_seconds)
      end
    end
  end
end
