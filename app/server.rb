require "socket"

print("Logs from your program will appear here!")

server = TCPServer.new("localhost", 4221)

loop do
  client = server.accept
  client.puts "HTTP/1.1 200 OK\r\n\r\n"
  client.close
end
