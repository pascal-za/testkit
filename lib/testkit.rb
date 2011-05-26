require 'capybara/driver/headless'

module TestKit
  class InitError < Exception; end;
  
  module UI
    def echo(message, color=nil)
      STDOUT.print color || white, message, reset, "\n"
    end
  end
end

require 'testkit/session'
