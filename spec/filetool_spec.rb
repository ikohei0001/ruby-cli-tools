require_relative "../lib/filetool.rb"
require "tempfile"
require "tmpdir"
require "fileutils"

RSpec.describe "filetool" do
  it "shows file content" do
    file = Tempfile.new('test')
    file.write("hello\nworld\n")
    file.close

    output = `ruby bin/filetool show #{file.path}`

    expect(output).to include("hello")
    expect(output).to include("world")
  end

  it "shows file stats" do
    file = Tempfile.new('test')
    file.write("hello\n")
    file.close

    output = `ruby bin/filetool stats #{file.path}`

    expect(output).to include("Lines: 1")
    expect(output).to include("Words: 1")
    expect(output).to include("Chars: 6")
  end

  it "adds new text" do
    file = Tempfile.new('test')
    file.write("hello\n")
    file.close

   `ruby bin/filetool add #{file.path} "world"`

   content = File.read(file.path)
    expect(content).to include("hello")
    expect(content).to include("world")
  end

  it "searches a string in a file" do
    file = Tempfile.new('test')
    file.write("hello\nworld\n")
    file.close

    output = `ruby bin/filetool search #{file.path} "hello"`

    expect(output).to include("hello")
  end

  it "the i option works" do
    file = Tempfile.new("test")
    File.write(file, "hello world")

    expect(Filetool.search(file, "hello", {:ignore_case => true})).to eq(["1: hello world"])
  end

  it "the c option works" do
    file = Tempfile.new("test")
    File.write(file, "hello world")

    expect(Filetool.search(file, "hello", {:count => true})).to eq(1)
  end

  it "replaces a text for a given string" do
    file = Tempfile.new('test')
    file.write("hello\nworld\n")
    file.close

    `ruby bin/filetool replace #{file.path} "world" "country"`

    content = File.read(file.path)
    expect(content).to include("country")
    expect(content).not_to include("world")
  end

  it "creates a new file" do
    filename = "test.txt"
    
    File.delete(filename) if File.exist?(filename)

    Filetool.create(filename)
    expect(File.exist?(filename)).to be true

    File.delete(filename)
  end

  it "does not create a new file because of existing file" do
    File.write("test.txt", "hello") 

    expect { Filetool.create("test.txt") }.to raise_error(RuntimeError, "File already exists: test.txt")

    File.delete("test.txt") if File.exist?("test.txt")
  end

  it "deletes a file" do
    file = Tempfile.new("test")
    Filetool.delete(file.path)

    expect(File.exist?(file.path)).to be false
  end

  it "does not delete a file that does not exist" do
    expect { Filetool.delete("no_file.txt") }.to raise_error("File not found: no_file.txt")
  end

  it "renames a file" do
    file = Tempfile.new('test')
    new_path = file.path + "_rename"
    Filetool.rename(file.path, new_path)

    expect(File.exist?(new_path)).to be true

    File.delete(new_path)
  end

  it "raises error when new file already exists" do
    Tempfile.create("old") do |old_file|
      Tempfile.create("new") do |new_file|

        expect { Filetool.rename(old_file.path, new_file.path)}.to raise_error("File already exist: #{new_file.path}")
      end
    end
  end

  it "makes a directory" do
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "test")
      Filetool.mkdir(path)

      expect(Dir.exist?(path)).to be true
    end
  end

  it "does not make a existing file"  do
    Dir.mktmpdir do |dir|
      expect { Filetool.mkdir(dir) }.to raise_error("Directory exist: #{dir}")
    end
  end

  it "deletes a directory" do
    tmp = Dir.mktmpdir

    Filetool.rmdir(tmp)

    expect(Dir.exist?(tmp)).to be false
  end

  it "does not delete a directory that does not exist" do
    dirname = "not_exist"

    expect(Dir.exist?(dirname)).to be false
    expect { Filetool.rmdir(dirname) }.to raise_error("Directory not found: #{dirname}")
  end

  it "does not delete a non-empty directory" do
    Dir.mktmpdir do |tmp|
      File.write(File.join(tmp, "test"), "")

      expect { Filetool.rmdir(tmp) }.to raise_error("Directory is not empty: #{tmp}")
    end
  end

  it "raises error when directory does not exist" do
    dir = "no such directory"
    expect { Filetool.ls(dir) }.to raise_error("No such directory: #{dir}")
  end

  it "shows file and directory" do
    dir = "temp"
    Dir.mkdir(dir)
    File.write(File.join(dir, "test.txt"), "")
    Dir.mkdir(File.join(dir, "subdir"))

    result = Filetool.ls(dir)
    expect(result).to contain_exactly(
      format("%-12s%s", "", "test.txt"),
      format("%-12s%s", "Directory:", "subdir")
    )

    FileUtils.rm_rf(dir)
  end

  it "returns current directory" do
    expect(Filetool.pwd).to eq(Dir.pwd)
  end

  it "renames files by seqrename command"  do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "cat"), "")
      File.write(File.join(dir, "dog"), "")
      File.write(File.join(dir, "rabbit"), "")
      Dir.mkdir(File.join(dir, "subdir"))

      Dir.chdir(dir) do
        Filetool.seqrename("animal")
        files = Dir.children(dir)
        
        expect(files).to include("animal_001")
        expect(files).to include("animal_002")
        expect(files).to include("animal_003")
        expect(files).to include("subdir")
      end
    end
  end
end