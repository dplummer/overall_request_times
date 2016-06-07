require "thread"
module OverallRequestTimes
  module Timer
    attr_reader :remote_app_name

    def timer_setup(remote_app_name, in_mutex = false)
      @remote_app_name = remote_app_name
      @timer_mutex = Mutex.new
      reset!
      OverallRequestTimes.register(self) unless in_mutex
    end

    def total
      @timer_mutex.synchronize do
        @total
      end
    end

    def reset!
      @timer_mutex.synchronize do
        @total = 0
      end
    end

    def add(some_time)
      @timer_mutex.synchronize do
        @total += some_time
      end
    end

    def start
      @started_at = Time.now
    end

    def stop
      return unless @started_at
      ended_at = Time.now
      add(ended_at.to_f - @started_at.to_f)
    end
  end
end
