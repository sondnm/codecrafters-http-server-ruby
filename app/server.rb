require "socket"

print("Logs from your program will appear here!")

server = TCPServer.new("localhost", 4221)

loop do
  client = server.accept

  request, _headers, _body = client.gets.split("\r\n")
  _protocol, path, _version = request.split(" ")

  if path == "/"
    client.puts "HTTP/1.1 200 OK\r\n\r\n"
  else
    client.puts "HTTP/1.1 404 Not Found\r\n\r\n"
  end
end
