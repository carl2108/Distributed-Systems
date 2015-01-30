class ChatClient1
  require 'socket'

  hostname = 'localhost'
  port = 8000
  s = TCPSocket.open(hostname, port)
  puts 'Connected'

  listenThread = Thread.new do
    loop{
      s = TCPSocket.open(hostname, port)
      x = s.readline
      puts "Message received: #{x}"
    }
  end

  talkThread = Thread.new do
    loop{
      puts 'Enter a message: '
      x = gets
      s.puts x
    }
  end

  listenThread.join
  talkThread.join
end