require "overall_request_times/version"
require "overall_request_times/railtie" if defined?(Rails)

module OverallRequestTimes
  autoload :Timer, "overall_request_times/timer"
  autoload :FaradayMiddleware, "overall_request_times/faraday_middleware"
  autoload :GenericTimer, "overall_request_times/generic_timer"
  autoload :RailsMiddleware, "overall_request_times/rails_middleware"
  autoload :Registry, "overall_request_times/registry"

  def self.registry
    @registry
  end

  def self.wipeout_registry
    @registry = Registry.new
  end

  def self.reset!
    registry.reset!
  end

  def self.register(timer)
    registry.register(timer)
  end

  def self.total_for(remote_app_name)
    registry.total_for(remote_app_name)
  end

  def self.totals
    registry.totals
  end

  def self.bm(remote_app_name, &block)
    registry.bm(remote_app_name, &block)
  end

  def self.start(remote_app_name)
    registry.start(remote_app_name)
  end

  def self.stop(remote_app_name)
    registry.stop(remote_app_name)
  end

  def self.add_duration(remote_app_name, duration_in_seconds)
    registry.add_duration(remote_app_name, duration_in_seconds)
  end
end

OverallRequestTimes.wipeout_registry
