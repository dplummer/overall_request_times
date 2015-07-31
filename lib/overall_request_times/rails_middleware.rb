module OverallRequestTimes
  class RailsMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      OverallRequestTimes.reset!
      @app.call(env)
    end
  end
end
