require "json"
require_relative "lists"

class Boards
  attr_reader :id, :lists

  @@id_count = 0

  def initialize(name:, description:, id: nil, lists: [])
    @id = id ? id : @@id_count + 1
    @@id_count = @id
    @name = name
    @description = description
    @lists = load_lists(lists)
  end

  def details
    lists = @lists.map { |list| "#{list.name}(#{list.cards.size})" }.join(", ")
    [@id, @name, @description, lists]
  end

  def load_lists(lists)
    lists.map { |list_hash| Lists.new(**list_hash) }
  end

  def update(name:, description:)
    @name = name unless name.empty?
    @description = description unless description.empty?
  end

  def to_json(_arg)
    { name: @name, description:@description, id: @id, lists: @lists}.to_json
  end
end