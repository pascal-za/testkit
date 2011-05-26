require 'socket'
require 'timeout'

module TestKit
  class Server
    include TestKit::UI
    
    attr_accessor :port
  
    def initialize
      @pid_file = Dir.pwd+'/tmp/pids/testkit.pid'
      @sock_file = Dir.pwd+'/tmp/sockets/testkit.sock'
      
      check_status
    end
    
    def check_status
      if File.exists?(@sock_file) && !is_port_available?(File.read(@sock_file).to_i)
        @pid = File.read(@pid_file).to_i
        echo "Application server seems to be running fine." if ENV['DEBUG']
      else
        start_server
      end
    end
    
    def start_server
      # Find a socket we can bind to
      unless @port
        TestKit.retryable(:tries => 5, :on => RuntimeError) do
          tcp_port = 20000+rand(10000)
          echo "Trying port #{tcp_port}" if ENV['DEBUG']
          is_port_available?(tcp_port) or raise
          @port = tcp_port

        end
        unless @port
          echo "BUG: Cannot detect an available TCP port to bind to, for now specify one manually in config.yml", red
          raise TestKit::InitError
        end
      end
      
      `thin --port #{@port} --pid #{@pid_file} --daemonize start`
            
      begin
        TestKit.wait_for(false, 30) do
          is_port_available?(@port)
        end
      rescue TimeoutError 
        echo "The application server failed to start, check your log to see why.", red
        raise TestKit::InitError
      end
      File.open(@sock_file, 'w') { |f| f.write(@port.to_s) }
    end
    
    def is_port_available?(port)
      begin
        Timeout::timeout(1) do
          begin
            s = TCPSocket.new('localhost', port)
            s.close
            return false
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return true
          end
        end
      rescue Timeout::Error
      end

      return false
    end
  end
end
