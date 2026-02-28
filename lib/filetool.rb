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

    Tempfile.create(File.basename(filename), File.dirname(filename)) do |tmp|
      File.foreach(filename).with_index(1) do |line, no|
        replaced = line.gsub(from, to)

        if replaced != line
        results << "#{no}: #{replaced.chomp}"
        end
        tmp.write(replaced)
      end

      tmp.flush
      tmp.fsync

      File.rename(tmp.path, filename)
    end
    results
  rescue Errno::ENOENT
    raise "File not found: #{filename}"
  end

  def create(filename)
    File.open(filename, "wx") {}
  rescue Errno::EEXIST
    raise "File already exists: #{filename}"
  end

  def delete(filename)
    File.delete(filename)
  rescue Errno::ENOENT
    raise "File not found: #{filename}"
  end

  def rename(old_name, new_name)
    File.link(old_name, new_name)
    File.unlink(old_name)
  rescue Errno::ENOENT
    raise "File not found: #{old_name}"
  rescue Errno::EEXIST
    raise "File already exist: #{new_name}"
  end

  def mkdir(dirname)
    Dir.mkdir(dirname)
  rescue  Errno::EEXIST
    raise "Directory exist: #{dirname}"
  end

  def rmdir(dirname)
    Dir.rmdir(dirname)
  rescue Errno::ENOENT
    raise "Directory not found: #{dirname}"
  rescue Errno::ENOTEMPTY
    raise "Directory is not empty: #{dirname}"
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

      begin
        new_name = "#{prefix}_#{format("%03d", count)}#{ext}"
        File.link(file, new_name)
        File.unlink(file)
        count += 1
      rescue Errno::EEXIST
        count += 1
        retry
      end
    end
  end
end


