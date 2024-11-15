require "socket"

print("Logs from your program will appear here!")

server = TCPServer.new("localhost", 4221)

loop do
  Thread.start(server.accept) do |client|
    _protocol, path, _version = client.gets.split(" ")

    case path
    when /\/echo\/.+/
      str = path.split("/").last
      response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: #{str.size}\r\n\r\n#{str}"
      client.puts response
    when /\/files\/.+/
      file_name = path.split("/").last
      file_path = "#{ARGV[1]}#{file_name}"

      if File.exist?(file_path)
        content = File.read(file_path)
        response = "HTTP/1.1 200 OK\r\nContent-Type: application/octet-stream\r\nContent-Length: #{content.size}\r\n\r\n#{content}"
        client.puts response
      else
        client.puts "HTTP/1.1 404 Not Found\r\n\r\n"
      end
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
