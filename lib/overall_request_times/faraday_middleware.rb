require 'faraday'

module OverallRequestTimes
  class FaradayMiddleware < ::Faraday::Middleware
    attr_reader :remote_app_name

    def initialize(app, remote_app_name)
      super(app)
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

    def call(request_env)
      started_at = Time.now
      @app.call(request_env).on_complete do |response_env|
        ended_at = Time.now
        add(ended_at - started_at)
      end
    end
  end
end
