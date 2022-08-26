require_relative "cards"

class Lists
  attr_reader :id, :name, :cards

  def initialize(id:, name:, cards:)
    @id = id
    @name = name
    @cards = load_cards(cards)
  end

  def load_cards(cards)
    cards.map { |card_hash| Cards.new(**card_hash) }
  end
end
