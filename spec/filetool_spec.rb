require_relative "../lib/filetool.rb"
require "tempfile"

RSpec.describe "filetool" do
  it "shows file content" do
    file = Tempfile.new('test')
    file.write("hello\nworld\n")
    file.close

    output = `ruby lib/filetool.rb show #{file.path}`

    expect(output).to include("hello")
    expect(output).to include("world")
  end

  it "shows file stats" do
    file = Tempfile.new('test')
    file.write("hello\n")
    file.close

    output = `ruby lib/filetool.rb stats #{file.path}`

    expect(output).to include("Lines: 1")
    expect(output).to include("Words: 1")
    expect(output).to include("Chars: 6")
  end
end