require "socket"
require "fileutils"

print("Logs from your program will appear here!")

server = TCPServer.new("localhost", 4221)

loop do
  Thread.start(server.accept) do |client|
    method, path, _version = client.gets.split(" ")

    case path
    when /\/echo\/.+/
      str = path.split("/").last
      response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: #{str.size}\r\n\r\n#{str}"
      client.puts response
    when /\/files\/.+/
      file_name = path.split("/").last
      directory = ARGV[1]
      FileUtils.mkdir_p directory
      file_path = "#{directory}#{file_name}"

      case method
      when "GET"
        if File.exist?(file_path)
          content = File.read(file_path)
          response = "HTTP/1.1 200 OK\r\nContent-Type: application/octet-stream\r\nContent-Length: #{content.size}\r\n\r\n#{content}"
          client.puts response
        else
          client.puts "HTTP/1.1 404 Not Found\r\n\r\n"
        end
      when "POST"
        body = nil
        content_length = 0
        loop do
          line = client.gets
          if line == "\r\n"
            body = client.read(content_length)
            break
          elsif line.start_with?("Content-Length:")
            content_length = line.split(" ").last.to_i
          end
        end

        File.write(file_path, body.to_s)
        client.puts "HTTP/1.1 201 Created\r\n\r\n"
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
