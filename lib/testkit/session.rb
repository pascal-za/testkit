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
  
    def initialize(root=Dir.pwd, features_root=Dir.pwd+'/test/integration/')
      @features_root = features_root
      
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

    
    def a
      Dir[@features_root+'**/*.rb'].each do |feature_file|
        f(feature_file.match(/\/([^\/]*)\.rb/)[1])
      end
      true
    end
    
    def f(feature)
      feature_file = "#{@features_root}/#{feature}.rb"
    
      begin
        load(feature_file)
      rescue LoadError
        echo feature_file+' does not exist', red
        return false
      end
      
      begin
        feature_klass = feature.classify.constantize
      rescue NameError
        echo "Congrats, you have #{feature_file}.\nNow, go define class #{feature.classify} < TestKit::Feature in it.", yellow
        return false
      end        
      echo feature_klass.to_s+"\n", bold
      feature_klass.new(@browser, "http://localhost:#{@port}/").run
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
