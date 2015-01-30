class TestC
  require 'socket'

  hostname = 'localhost'
  port = 8000
  s = TCPSocket.open(hostname, port)

  puts 'Connected'

  while x = s.readline
    puts x
  end


  puts 'done'

end