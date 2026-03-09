class Flashcards
  def initialize
    @words = {}
  end

  def add(english, japanese)
    @words[english] = japanese
  end

  def all
    @words
  end

  def find(english)
    @words[english]
  end
end