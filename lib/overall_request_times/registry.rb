require "thread"
module OverallRequestTimes
  class Registry
    def initialize
      @registry = {}
      @mutex = Mutex.new
    end

    def size
      @mutex.synchronize do
        @registry.size
      end
    end

    def reset!
      @mutex.synchronize do
        @registry.each { |_, timer| timer.reset! }
      end
    end

    def register(timer)
      @mutex.synchronize do
        @registry[timer.remote_app_name] ||= timer
      end
    end

    def total_for(remote_app_name)
      @mutex.synchronize do
        timer = @registry[remote_app_name]
        timer ? timer.total : 0
      end
    end

    def call_count_for(remote_app_name)
      @mutex.synchronize do
        timer = @registry[remote_app_name]
        timer ? timer.call_count : 0
      end
    end

    def totals
      @mutex.synchronize do
        @registry.each_with_object({}) do |(remote_app_name, timer), acc|
          acc[remote_app_name] = timer.total
        end
      end
    end

    def bm(remote_app_name, &block)
      start(remote_app_name)
      begin
        block.call
      ensure
        stop(remote_app_name)
      end
    end

    def start(remote_app_name)
      @mutex.synchronize do
        @registry[remote_app_name] ||= GenericTimer.new(remote_app_name, true)
        @registry[remote_app_name].start
      end
    end

    def stop(remote_app_name)
      @mutex.synchronize do
        @registry[remote_app_name] && @registry[remote_app_name].stop
      end
    end

    def add_duration(remote_app_name, duration_in_seconds)
      @mutex.synchronize do
        @registry[remote_app_name] ||= GenericTimer.new(remote_app_name, true)
        @registry[remote_app_name].add(duration_in_seconds)
      end
    end
  end
end
