module Filetool
  class << self
    def show(filename)
      File.read(filename)
    end
  
    def stats(filename)
      lines = 0
      words = 0
      chars = 0

      File.foreach(filename) do |line|
        lines += 1
        words += line.split.size
        chars += line.length
      end

      { lines: lines, words: words, chars: chars }
    end

    def add(filename, text)
      File.open(filename, 'a') { |f| f.puts text }
    end

    def search(filename, string)
      results = []
      File.foreach(filename).with_index(1) do |line, no|
        if line.include?(string)
          results << "#{no}: #{line}"
        end
      end
      results
    end
  end
end

