module OverallRequestTimes
  class GenericTimer
    attr_reader :remote_app_name

    def initialize(remote_app_name)
      @remote_app_name = remote_app_name
      reset!
      OverallRequestTimes.register(self)
    end

    def total
      @total
    end

    def reset!
      @total = 0
    end

    def add(some_time)
      @total += some_time
    end

    def start
      @started_at = Time.now
    end

    def stop
      return unless @started_at
      ended_at = Time.now
      add(ended_at - @started_at)
    end
  end
end
