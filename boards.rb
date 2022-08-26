require "json"

class Boards
  @@id_count = 0

  def initialize(name:, description:, id: nil, lists: [])
    @id = id ? id : @@id_count + 1
    @@id_count = @id
    @name = name
    @description = description
    @lists = lists
  end

  def details
    lists_array = @lists.map {|e| "#{e[:name]}(#{e[:cards].size})"} 
    [@id, @name, @description, "#{lists_array.join(', ')}"]
  end

  def to_json(_arg)
    {id: @id, name: @name, description: @description, lists: @lists}.to_json
  end
end
