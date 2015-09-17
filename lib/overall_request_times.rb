require "overall_request_times/version"
require "overall_request_times/railtie" if defined?(Rails)

module OverallRequestTimes
  autoload :Timer, "overall_request_times/timer"
  autoload :FaradayMiddleware, "overall_request_times/faraday_middleware"
  autoload :GenericTimer, "overall_request_times/generic_timer"
  autoload :RailsMiddleware, "overall_request_times/rails_middleware"

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

  def self.totals
    registry.each_with_object({}) do |(remote_app_name, timer), acc|
      acc[remote_app_name] = timer.total
    end
  end

  def self.bm(remote_app_name, &block)
    start(remote_app_name)
    begin
      block.call
    ensure
      stop(remote_app_name)
    end
  end

  def self.start(remote_app_name)
    registry[remote_app_name] ||= GenericTimer.new(remote_app_name)
    registry[remote_app_name].start
  end

  def self.stop(remote_app_name)
    registry[remote_app_name] && registry[remote_app_name].stop
  end

  def self.add_duration(remote_app_name, duration_in_seconds)
    registry[remote_app_name] ||= GenericTimer.new(remote_app_name)
    registry[remote_app_name].add(duration_in_seconds)
  end
end
