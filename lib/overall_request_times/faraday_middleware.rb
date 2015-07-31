require 'faraday'

module OverallRequestTimes
  class FaradayMiddleware < ::Faraday::Middleware
    include Timer

    def initialize(app, remote_app_name)
      super(app)
      timer_setup(remote_app_name)
    end

    def call(request_env)
      start
      @app.call(request_env).on_complete do |response_env|
        stop
      end
    end
  end
end
