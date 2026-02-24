require "tempfile"

module Filetool
  module_function
  def show(path)
    File.read(path)
  end

  def stats(path)
    content = File.read(path)

    {
      lines: content.lines.count,
      words: content.split.size,
      chars: content.length
    }
  end

  def add(filename, text)
    File.open(filename, 'a') { |f| f.puts text }
  end

  def search(path, string, options = {})
    results = []
    
    flags = options[:ignore_case] ? Regexp::IGNORECASE : nil
    pattern = Regexp.new(Regexp.escape(string), flags)

    File.foreach(path).with_index(1) do |line, no|
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
    raise "File already exists" if File.exist?(filename)
    File.write(filename, "")
  end

  def delete(filename)
    raise "File not found" unless File.exist?(filename)
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

  def ls(dirname)
    raise "No such directory: #{dirname}"  unless Dir.exist?(dirname)

    Dir.children(dirname).map do |name|
      path = File.join(dirname, name)
      format("%-12s%s", File.directory?(path) ? "Directory:" : "", name)
    end
  end

  def pwd
    Dir.pwd
  end

  def cd(path)
    Dir.chdir(path)
    Dir.pwd
  end

  def seqrename(prefix = "file")
    count = 1

    files = Dir.glob("*")
               .select { |f| File.file?(f) }
               .reject { |f| f.match?(/^#{Regexp.escape(prefix)}_\d{3}/) }
               .sort
    
    files.each do |file|
      ext = File.extname(file)

      loop do
        new_name = "#{prefix}_#{format("%03d", count)}#{ext}"
        if File.exist?(new_name)
          count += 1
          next
        end

        File.rename(file, new_name)
        count += 1
        break
      end
    end
  end
end


