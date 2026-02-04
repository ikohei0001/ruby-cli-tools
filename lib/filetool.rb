
command = ARGV[0]
filename = ARGV[1]
text = ARGV[2]

if command.nil? || filename.nil?
  puts "Usage:"
  puts " ruby filetool.rb show <file>"
  puts " ruby filetool.rb stats <file>"
  puts " ruby filetool.rb add <file> \"text\""
  exit
end

unless File.exist?(filename)
  puts "File not found: #{filename}"
  exit
end

case command
when "show"
  File.open(filename, 'r') do |file|
    puts file.read
  end

when "stats"
  lines = 0
  words = 0
  chars = 0

  File.open(filename, 'r') do |file|
    file.each_line do |line|
      lines += 1
      words += line.split.size
      chars += line.length
    end
  end

  puts "Lines: #{lines}"
  puts "words: #{words}"
  puts "chars: #{chars}"

when "add"
  if text.nil?
    puts "Text to add is missing"
    exit
  end

  File.open(filename, 'a') do |file|
    file.puts text
  end

  puts "Add text to #{filename}"

else
  puts "unknown command: #{command}"  
end

