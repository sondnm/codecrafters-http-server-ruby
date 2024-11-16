require "socket"
require "fileutils"

print("Logs from your program will appear here!")

server = TCPServer.new("localhost", 4221)

loop do
  Thread.start(server.accept) do |client|
    method, path, _version = client.gets.split(" ")
    header_arr = []
    loop do
      line = client.gets.strip

      line.empty? ? break : header_arr.push(line)
    end
    headers = header_arr.each_with_object({}) do |header, obj|
      key, value = header.split(": ")
      obj[key] = value
    end
    content_length = headers["Content-Length"].to_i
    body = client.read(content_length)

    accept_encoding = headers["Accept-Encoding"]
    content_encoding = "gzip" if accept_encoding === "gzip"

    case path
    when /\/echo\/.+/
      content = path.split("/").last
      client.puts "HTTP/1.1 200 OK\r\n"
      client.puts "Content-Encoding: #{content_encoding}\r\n" if content_encoding
      client.puts "Content-Type: text/plain\r\n"
      client.puts "Content-Length: #{content.size}\r\n\r\n"
      client.puts content
    when /\/files\/.+/
      file_name = path.split("/").last
      directory = ARGV[1]
      FileUtils.mkdir_p directory
      file_path = "#{directory}#{file_name}"

      case method
      when "GET"
        if File.exist?(file_path)
          content = File.read(file_path)
          client.puts "HTTP/1.1 200 OK\r\n"
          client.puts "Content-Type: application/octet-stream\r\n"
          client.puts "Content-Length: #{content.size}\r\n\r\n"
          client.puts content
        else
          client.puts "HTTP/1.1 404 Not Found\r\n\r\n"
        end
      when "POST"
        File.write(file_path, body.to_s)
        client.puts "HTTP/1.1 201 Created\r\n\r\n"
      else
        client.puts "HTTP/1.1 404 Not Found\r\n\r\n"
      end
    when "/user-agent"
      user_agent = headers["User-Agent"]

      if user_agent.nil?
        client.puts "HTTP/1.1 404 Not Found\r\n\r\n"
      else
        client.puts "HTTP/1.1 200 OK\r\n"
        client.puts "Content-Type: text/plain\r\n"
        client.puts "Content-Length: #{user_agent.size}\r\n\r\n"
        client.puts user_agent
      end
    when "/"
      client.puts "HTTP/1.1 200 OK\r\n\r\n"
    else
      client.puts "HTTP/1.1 404 Not Found\r\n\r\n"
    end
  end
end
