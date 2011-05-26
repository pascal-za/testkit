require 'capybara/driver/headless'
require 'ansi'
require 'timeout'

module TestKit
  class InitError < Exception; end;
  
  module UI
    include ANSI::Code
  
    def echo(message, color=nil)
      STDOUT.print color || white, message, reset, "\n"
    end
  end
  
  class << self
    def retryable(options = {}, &block)
      opts = { :tries => 1, :on => Exception }.merge(options)

      retry_exception, retries = opts[:on], opts[:tries]
      begin
        return yield
      rescue retry_exception
        retry if (retries -= 1) > 0
      end
    end
    
    def wait_for(expected_value, seconds_to_wait, &block)
      factor = Math.sqrt(seconds_to_wait.to_f)
      wait_time = 0.01
      start = Time.now.to_f
    
      while (Time.now.to_f-start) < seconds_to_wait.to_f
        return expected_value if yield == expected_value

        # Exponential backoff
        sleep(Math.sqrt(Time.now.to_f-start) / factor)
      end
      raise Timeout::Error
    end
  end
end

require 'testkit/session'
