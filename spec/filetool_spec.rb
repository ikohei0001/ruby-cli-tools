require_relative "../lib/filetool.rb"
require "tempfile"

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
end