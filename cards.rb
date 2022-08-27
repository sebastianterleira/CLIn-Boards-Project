class Cards
  attr_reader :id, :title, :members, :labels, :due_date, :checklist
  @@id_count = 0
  def initialize(id:nil, title:, members:[], labels:[], due_date:, checklist:[])
    @id = id ? id : @@id_count + 1
    @@id_count = @id
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

  def update( title:, members:[], labels:[], due_date: )
    @title = title
    @members = members
    @labels = labels
    @due_date = due_date
  end

  def to_json(_arg)
    { title: @title, members:@members, id: @id, labels: @labels, due_date: @due_date, checklist: @checklist}.to_json
  end
end
