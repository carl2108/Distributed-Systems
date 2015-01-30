class Test
  require 'socket'


  host = 8000
  server = TCPServer.open(host)
  s = server.accept
  puts 'Connected'

  for i in(1...50) do
    s.puts i
  end
  puts 'closing'
  s.close
  puts 'server closed'
end