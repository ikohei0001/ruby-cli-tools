require "tempfile"

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

    def search(filename, string, options = {})
      results = []
      
      pattern = options[:ignore_case] ? /#{Regexp.escape(string)}/i : string

      File.foreach(filename).with_index(1) do |line, no|
        if line.match?(pattern)
          if options[:count]
            results << no
          else
            results << "#{no}: #{line}"
          end
        end
      end

      if options[:count]
        return results.size
      end

      results
    end

    def replace!(filename, from, to)
      results = []

      Tempfile.create do |tmp|
        File.foreach(filename).with_index(1) do |line, no|
          if line.match?(from)
            replaced = line.gsub(from, to)
            results << "#{no}: #{replaced.chomp}"
            tmp.write(replaced)
          else
            tmp.write(line)
          end
        end

        tmp.flush
        File.write(filename, File.read(tmp.path))
      end
      results
    end

    def create(filename)
      if File.exist?(filename)
        raise "File already exists"
      end
      File.write(filename, "")
    end

    def delete(filename)
      unless File.exist?(filename)
        return "File not found"
      end
      File.delete(filename)
    end

    def rename(old_name, new_name)
      raise "File not found #{old_name}" unless File.exist?(old_name)
      raise "File already exist: #{new_name}" if File.exist?(new_name)

      File.rename(old_name, new_name)
    end

    def mkdir(dirname)
      raise "Directory exist: #{dirname}" if Dir.exist?(dirname)

      Dir.mkdir(dirname)
    end

    def rmdir(dirname)
      raise "No such directory: #{dirname}" unless Dir.exist?(dirname)
      raise "Directory is not empty: #{dirname}" unless Dir.empty?(dirname)

      Dir.rmdir(dirname)
    end
  end
end


