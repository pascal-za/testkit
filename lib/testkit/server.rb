module TestKit
  class Server
    include TestKit::UI
  
    def initialize(root=Dir.pwd)
      @root = Dir.pwd
      check_status
    end
    
    def check_status
      pid_file = @root.join('tmp', 'testkid.pid')
    
      if File.exists?(pid_file)
        @pid = File.read(pid_file)
        
        # Is the server still alive?
        begin
          Process.kill('USR1', @pid.to_i)
        rescue Errno::ESRCH
          File.unlink(pid_file)
          start_server
        end
      end
    end
  end

end
