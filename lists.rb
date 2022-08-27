require_relative "cards"

class Lists
  attr_reader :id, :name, :cards
  @@id_count = 0
  def initialize(id:nil, name:, cards:[])
    @id = id || (@@id_count + 1)
    @@id_count = @id
    @name = name
    @cards = load_cards(cards)
  end

  def load_cards(cards)
    cards.map { |card_hash| Cards.new(**card_hash) }
  end

  def update(name:)
    @name=name unless name.empty?
  end

  def to_json(_arg)
    { name: @name, id: @@id_count, cards: @cards}.to_json
  end
end
