require 'testkit/assertions'
require 'testkit/actions'

module TestKit
  class Feature
    include TestKit::UI
    include Test::Unit::Assertions
    include TestKit::Assertions
    include TestKit::Actions
    
    def initialize(browser, host)
      @browser = browser
      @host = host
    end
    
    def self.scenario(title, &block)
      @@scenarios ||= []
      define_method('test_'+title.underscore) do
        instance_eval(&block)
      end
      @@scenarios << title
    end
    
    def run
      @@scenarios.each do |scenario|
        print "  #{scenario}:"
        
        begin
          send('test_'+scenario.underscore)
          
        rescue => e
          echo "  EXCEPTION\n", red
          echo_snippet do
            echo "  #{e}", yellow 
            puts e.backtrace.collect { |line|
              filename = line.match(/\/.*\.rb/)
              line.sub!(/\/([^\/]*)\.rb/, bold+'/\1.rb'+reset) # File
              line.sub!(/(:\d+)/, white+'\1'+reset) # Line number
              
              if line.include?(self.class.to_s.underscore)
                line = yellow+"\n  * "+line.sub(/in .*/, '')+reset+" --> '#{scenario}'\n"
                line += white+File.readlines(filename[0])[line.match(/:(\d+)/)[1].to_i-1]+reset if filename && File.exists?(filename[0])
              else
                line.sub!(/in `([^`]*)'/, bold+' --> \1'+reset) # Method
                "  - "+line
              end
            }.join("\n")
          end
        end
      end
    end
    
    private
    def execute(name, *args)
      browser.command "Node", name, native, *args
    end
    
    def template(*args)
      # To be implemented
      ''
    end
  end
end
