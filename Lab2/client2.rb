class Test2
  require 'socket'

  hostname = 'localhost'
  port = 8000
  path = "/echo.php?message=convert+me"

  loop {
    #request = "GET #{path} HTTP/1.0\r\n\r\n"
    s = TCPSocket.open(hostname, port)
    # s.print(request)
    s.puts("HELO\n")
    puts s.read
    sleep(0.2)
    #response = s.read
    #print response
  }

end