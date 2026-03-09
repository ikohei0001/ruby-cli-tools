require_relative "../lib/flashcards.rb"

RSpec.describe Flashcards do
  it "can add words" do
    cards = Flashcards.new
    cards.add('apple', 'りんご')

    expect(cards.find('apple')).to eq('りんご')
  end

  it "can get the list" do
    cards = Flashcards.new
    cards.add('sun', '太陽')
    cards.add('moon', '月')

    expect(cards.all).to include("sun" => "太陽")
    expect(cards.all).to include("moon" => "月")
  end
end