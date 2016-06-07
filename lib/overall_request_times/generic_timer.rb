module OverallRequestTimes
  class GenericTimer
    include Timer

    def initialize(remote_app_name, in_mutex = false)
      timer_setup(remote_app_name, in_mutex)
    end
  end
end
