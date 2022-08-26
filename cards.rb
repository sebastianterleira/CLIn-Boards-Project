class Cards
  attr_reader :id, :title, :members, :labels, :due_date, :checklist

  def initialize(id:, title:, members:, labels:, due_date:, checklist:)
    @id = id
    @title = title
    @members = members
    @labels = labels
    @due_date = due_date
    @checklist = checklist
  end

  def details
    count = 0
    @checklist.map { |chk| count += 1 if chk[:completed] }
    [@id, @title, @members.join(", "), @labels.join(", "), @due_date, "#{count}/#{@checklist.size}"]
  end
end
