class Test_S
  require 'thread'
  require 'socket'

  port = 8000
  host = 'localhost'

  work_q= Queue.new

  server = TCPServer.open(port)
  puts 'listening...'

  numThreads = 25

  listenThread = Thread.new do
    loop{
      s = server.accept
      work_q.push s
    }
  end

  workers = (0...25).map do
    Thread.new do
      loop{
        x = work_q.pop  #Pop next connection
        req = x.readline

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

end