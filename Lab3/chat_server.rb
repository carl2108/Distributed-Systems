class ChatServer
  require 'thread'
  require 'socket'

  def ChatServer.process(x, req)
    x.puts 'Unknown Message'
    x.puts 'unknown message 2'
  end

  host = 8000 #ARGV[0]  #Takes in parameter from the bash script/shell
  server = TCPServer.open(host)
  work_q = Queue.new
  student_no = 10352941
  puts 'listening...'

  #Listening thread - accepts connections and pushes to stack/queue to be processed later
  listenThread = Thread.new do
    loop{
      s = server.accept
      work_q.push s
    }
  end

  #Array of 4 worker threads - process requests from the stack/queue
  workers = (0...4).map do
    Thread.new do
      loop{
        x = work_q.pop  #Pop next connection to be handled
        req = x.readline
        puts 'Thread: ' + Thread.current.object_id.to_s + ' || Message: ' + req

        #Change for switch & case statement?
        if req[0, 4] == 'HELO'
          _, remote_port, _, remote_ip = x.peeraddr #sock_domain, remote_port, remote_hostname, remote_ip = socket.peeraddr
          x.puts req + "IP: #{remote_ip}\nPort: #{remote_port}\nStudentID: #{student_no}"
        elsif req == "KILL_SERVICE\n"
          x.puts('ABORT')
          abort('Goodbye')    #shut down server
        else
          process(x, req) #Or process other message
        end
      }
    end
  end

  #Join threads - executes threads
  workers.each {|worker| worker.join}
  listenThread.join
end