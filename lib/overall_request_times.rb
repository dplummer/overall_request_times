require "overall_request_times/version"
require "overall_request_times/timer"
require "overall_request_times/faraday_middleware"
require "overall_request_times/generic_timer"
require "overall_request_times/rails_middleware"
require "overall_request_times/railtie" if defined?(Rails)

module OverallRequestTimes
  def self.wipeout_registry
    @registry = nil
  end

  def self.registry
    @registry ||= {}
  end

  def self.reset!
    registry.each { |_, timer| timer.reset! }
  end

  def self.register(timer)
    registry[timer.remote_app_name] ||= timer
  end

  def self.total_for(remote_app_name)
    timer = registry[remote_app_name]
    timer ? timer.total : 0
  end
end
