require "socket"

print("Logs from your program will appear here!")

server = TCPServer.new("localhost", 4221)

loop do
  Thread.start(server.accept) do |client|
    request = client.gets
    _protocol, path, _version = request.split(" ")

    case path
    when /\/echo\/(.+)/
      str = Regexp.last_match(1)
      response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: #{str.size}\r\n\r\n#{str}"
        client.puts response
    when "/user-agent"
      header = ""
      loop do
        header = client.gets
        header.match?(/^User-Agent: .*$/) ? break : header = ""
      end

      if header.empty?
        client.puts "HTTP/1.1 404 Not Found\r\n\r\n"
      else
        _header_key, header_value = header.split(" ")
        response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: #{header_value.size}\r\n\r\n#{header_value}"
          client.puts response
      end
    when "/"
      client.puts "HTTP/1.1 200 OK\r\n\r\n"
    else
      client.puts "HTTP/1.1 404 Not Found\r\n\r\n"
    end
  end
end
