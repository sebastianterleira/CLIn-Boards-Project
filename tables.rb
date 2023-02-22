module Tables
  def menu(message, options)
    message.each_with_index do |_m, i|
      puts "#{message[i]}#{options[i].join(' | ')}"
    end
    print "> "
    action, *arg = gets.chomp.split
    arg = arg.join(" ")
    arg = "" if arg.nil?
    arg = arg.to_i if arg.match(/\d/)
    [action, arg]
  end

  def initialize_table(board)
    board.lists.each do |list|
      title, headings, cards = grab_table_data(list)
      print_table(title: title, headings: headings, list: cards)
    end
  end

  def print_table(list:, title:, headings:)
    table = Terminal::Table.new
    table.title = title
    table.headings = headings
    table.rows = list.map(&:details)
    puts table
  end

  def grab_table_data(list)
    [list.name, ["ID", "Title", "Members", "Labels", "Due Date", "Checklist"], list.cards]
  end

  def grab_menu_data
    [["List options: ", "Card options: ", ""],
     [["create-list", "update-list LISTNAME", "delete-list LISTNAME"],
      ["create-card", "checklist ID", "update-card ID", "delete-card ID"], ["back"]]]
  end

  def find_board(id, boards)
    boards.find { |e| e.id == id }
  end

  def find_list(list_name, board)
    board.lists.find { |l| l.name.capitalize == list_name }
  end

  def find_card(card_id, list)
    list.cards.find { |c| c.id == card_id }
  end

  def save(filename, boards)
    File.write(filename, boards.to_json)
  end

  def board_form
    print "Name: "
    name = gets.chomp
    print "Description: "
    description = gets.chomp
    { name: name, description: description }
  end

  def list_card(board)
    puts "Select a list: "
    list_menu = []
    board.lists.each do |list|
      list_menu.push(list.name)
    end
    puts list_menu.join(" | ").to_s
    print "> "
    gets.chomp
  end

  def card_details_form
    print "Title: "
    title = gets.chomp
    print "Members: "
    members = gets.chomp.split(",")
    print "Labels: "
    labels = gets.chomp.split(",")
    print "Due date: "
    due_date = gets.chomp
    { title: title, members: members, labels: labels, due_date: due_date }
  end

  def list_form
    print "Name: "
    name = gets.chomp
    { name: name }
  end

  def fetch_card(id, board)
    board.lists.each do |list|
      card = list.cards.find { |c| c.id == id }
      return card unless card.nil?
    end
  end

  def print_card(card)
    puts "Card: #{card.title}"

    card.checklist.each_with_index do |chk, i|
      check = " "
      check = "x" if chk[:completed]
      puts "[#{check}] #{i + 1}. #{chk[:title]}"
    end
    puts "-" * 37
  end

  def find_list_by_card_id(card_id, board)
    lists = board.lists.map do |list|
      c = list.cards.find { |card| card.id == card_id }
      return list if list.cards.include?(c)
    end
    list_with_card = ""
    lists.each do |list|
      list_with_card = list unless list.nil?
    end
    list_with_card
  end

  def find_card_by_id_without_list(card_id, board)
    cards = board.lists.map do |list|
      list.cards.find { |c| c.id == card_id }
    end
    card_selected = ""
    cards.each do |card|
      card_selected = card unless card.nil?
    end
    card_selected
  end
end
