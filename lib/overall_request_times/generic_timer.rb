module OverallRequestTimes
  class GenericTimer
    include Timer

    def initialize(remote_app_name)
      timer_setup(remote_app_name)
    end
  end
end
