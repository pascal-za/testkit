require 'ripl'
require 'capybara/driver/headless'
require 'testkit/server'

module TestKit
  class InitError < Exception; end;
  
  class Session
    include TestKit::UI
    
    COMMANDS = {
      'a' => 'Runs the entire test suite',
      'x' => 'Runs all tests that failed last time around',
      'f' => 'Runs the specified feature. Example: "f businesses" will run test/features/businesses.rb',
      'r' => 'Force Reloads the current application fully (should happen automatically)',
      'exit' => 'Terminates the testing session'
    }
  
    def initialize(root=Dir.pwd)
      Dir.chdir(root) do
        echo "Booting Webkit..."
        @browser = WebkitHeadless::Browser.new
        echo "Booting Application Server..."
        @server = TestKit::Server.new
        
        echo "Type help [command] for more information"
        COMMANDS.each do |shortcut, description|
          define_singleton_method(shortcut+'?') { STDOUT.print white, shortcut, reset, ":  #{description}\n" }
        end
        
        Ripl.start :binding => instance_eval { binding }, :prompt => 'TestKit Session ['+green+Dir.pwd.sub(/.*\//, '')+reset+"]: "
      end
    rescue TestKit::InitError
      exit # Should already be an error from upstream, so just terminate
    end
    
    def help(*args)
      COMMANDS.each do |name, command|
        STDOUT.print '  [', bold, name, reset, ']: ', white, command, reset, "\n"
      end
      
      echo "\nType a command followed by ? to see more about it"
      nil
    end
        
    def method_missing(*args)
      echo("Command not found: #{args.first}", red)
      
      "Available commands: "+COMMANDS.keys.join(', ')
    end
  end
end
