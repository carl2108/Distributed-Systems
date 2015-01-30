class ChatServer
  require 'thread'
  require 'socket'

  #Function to determine message type
  def ChatServer.process(x, req)
    #Join chat room protocol
    if req[0, 15] == 'JOIN_CHATROOM: '
      joinHandle(x, req)

    #Leave chat room protocol
    elsif req[0, 16] == 'LEAVE_CHATROOM: '
      leaveHandle(x, req)

    #Disconnect from server protocol
    elsif req[0, 12] == 'DISCONNECT: '
      disconnectHandle(x, req)

    #Send chat message protocol
    elsif req[0, 6] == 'CHAT: '
      messageHandle(x, req)

    #Otherwise unrecognised protocol message
    else
      raise 'INVALID MESSAGE'
    end

  end

  #Handle join
  def joinHandle(x, req)
      #Read in room_name
      room_name = req[15, req.length]
      client_IP = 0
      client_port = 0

      #Read in and ignore CLIENT_IP
      if x.readline[0, 11] != 'CLIENT_IP: '
        errorMessage(x, 1, 'CLIENT_IP')
      end

      #Read in and ignore PORT
      if x.readline[0, 6] != 'PORT: '
        errorMessage(x, 1, 'PORT')
      end

      #Read in CLIENT_NAME
      client_name = x.readline
      if client_name[0, 13] != 'CLIENT_NAME: '
        errorMessage(x, 1, 'CLIENT_NAME')
      else
        client_name = client_name[13, client_name.length]
      end

      #Then add client_name to room_name client list!
      #Get room_reference number using room_name
      #Join_ID = client_number + room_reference

      #Respond
      x.puts "JOINED_CHATROOM: #{room_name}/nSERVER_IP: #{}/nPORT: #{}/nROOM_REF: #{}/nJOIN_ID: #{}"
    end

  #Handle leave
  def leaveHandle(x, req)
    #Read in room_ref
    room_ref = req[16, req.length]

    #Read in JOIN_ID
    req = x.readline
    if req[0, 9] != 'JOIN_ID: '
      errorMessage(x, 2, 'JOIN_ID')
    else
      join_id = req[9, req.length]
    end

    #Read in CLIENT_NAME
    req = x.readline
    if req[0, 13] != 'CLIENT_NAME: '
      errorMessage(x, 2, 'CLIENT_NAME')
    else
      client_name = req[13, req.length]
    end

    #Respond
    x.puts "LEFT_CHATROOM: #{room_ref}/nJOIN_ID: #{join_id}"


  end

  #Disconnect handle
  def disconnectHandle(x, req)
    #Read in and ignore IP address
    #Read in and ignore Port
    req = x.readline
    if req[0, 6] != 'PORT: '
      errorMessage(x, 3, 'PORT')
    end

    #Read in client_name
    req = x.readline
    if req[0, 13] != 'CLIENT_NAME: '
      errorMessage(x, 3, 'CLIENT_NAME')
    else
      client_name = req[13, req.length]
    end
    Thread.current.thread_variable_set(:busy, 0)
  end

  #Message handle
  def messageHandle(x, req)
    #Read in room_ref
    room_ref = req[6, req.length]

    #Read in join_id
    req = x.readline
    if req[0, 9] != 'JOIN_ID: '
      errorMessage(x, 4, 'JOIN_ID')
    else
      join_id = req[9, req.length]
    end

    #Forward message to appropriate chat room members including sender

  end

  #Error messaging function
  def errorMessage(x, i, s)
    if i == 1
      t = 'Joining'
    elsif i == 2
      t = 'Leaving'
    elsif i == 3
      t = 'Disconnect'
    elsif i == 4
      t = 'Message'
    else
      t = 'Unknown'
    end

    #Respond with error message
    x.puts "ERROR_CODE: #{i}/nERROR_DESCRIPTION: #{t} error"
    raise "Error #{i}, #{t} error, #{s}"

  end

  #Main starts here!

  host = 8000 #ARGV[0]  #Takes in parameter from the bash script/shell
  server = TCPServer.open(host)
  work_q = Queue.new
  student_no = 10352941
  puts 'listening...'

  #Listening thread - accepts clients and pushes to stack/queue to be processed
  listenThread = Thread.new do
    loop{
      s = server.accept
      work_q.push s
    }
  end

  #Array of 4 worker threads - process clients from the stack/queue
  workers = (0...10).map do
    Thread.new do
      loop{
        x = work_q.pop  #Pop next client to be handled
        Thread.current.thread_variable_set(:busy, 1) #Set thread as busy

        while Thread.current.thread_variable_get(:busy) == 1
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

        end
      }
    end
  end

  #Join threads - executes threads
  workers.each {|worker| worker.join}
  listenThread.join
end