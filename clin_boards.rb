require "terminal-table"
require "json"
require_relative "boards"

class ClinBoards
  def initialize(filename)
    @filename = filename
    @boards = load_boards
  end

  def start
    welcome_message
    action = ""
    until action == "exit"
      print_table(list: @boards, title: "CLIn Boards", headings: ["ID", "Name", "Description", "List(#cards)"])

      action, id = menu(["Board options: "], [["create", "show ID", "update ID", "delete ID", "exit"]])

      case action
      when "create" then create_board(@boards)
      when "show" then show_board(id)
      when "update" then update_board(id)
      when "delete" then delete_board(id)
      when "exit" then exit
      else
        puts "Invalid action"
      end
    end
  end

  private

  def create_board(boards)
    board_hash = board_form
    new_board = Boards.new(**board_hash)
    boards.push(new_board)
    File.write(@filename, boards.to_json)
  end

  def board_form
    print "Name: "
    name = gets.chomp
    print "Description: "
    description = gets.chomp
    { name: name, description: description }
  end

  def welcome_message
    puts "#" * 36
    puts "##{' ' * 6}Welcome to CLIn Boards#{' ' * 6}#"
    puts "#" * 36
  end

  def menu(message, options)
    message.each_with_index do |_m, i|
      puts "#{message[i]}#{options[i].join(' | ')}"
    end
    print "> "
    action, arg = gets.chomp.split
    arg = "" if arg.nil?
    arg = arg.to_i if arg.match(/\d/)
    [action, arg]
  end

  def print_table(list:, title:, headings:)
    table = Terminal::Table.new
    table.title = title
    table.headings = headings
    table.rows = list.map(&:details)
    puts table
  end

  def load_boards
    data = JSON.parse(File.read(@filename), symbolize_names: true)
    data.map { |board_hash| Boards.new(**board_hash) }
  end

  def show_board(id)
    board = @boards.find { |b| b.id == id }
    action = ""
    until action == "back"

      board.lists.each do |list|
        print_table(title: list.name, headings: ["ID", "Title", "Members", "Labels", "Due Date", "Checklist"],
                    list: list.cards)
      end

      action, arg = menu(["List options: ", "Card options: ", ""],
                         [["create-list", "update-list LISTNAME", "delete-list LISTNAME"],
                          ["create-card", "checklist ID", "update-card ID", "delete-card ID"], ["back"]])

      case action
      when "create-list" then puts "create-list!"
      when "update-list" then puts "update-list! #{arg}"
      when "delete-list" then puts "Udelete-list! #{arg}"
      when "create-card" then puts "create-card!"
      when "checklist" then show_checklist(arg, board)
      when "update-card" then puts "udate-card! #{arg}"
      when "delete-card" then puts "delete-card! #{arg}"
      else
        puts "Invalid action" unless action == "back"
      end
    end
  end
  def delete_board(id)
    board_selected=find_card(id)
    @boards.delete(board_selected)
    save
  end

  def update_board(id)
    board_selected=find_card(id)
    new_card_hash= board_form
    board_selected.update(**new_card_hash)
    save
  end

  def board_form
    print "Name: "
    name = gets.chomp
    print "Description: "
    description = gets.chomp
    { name: name, description: description }
  end

  def find_card(id)
    @boards.find { |e| e.id==id}
  end

  def save
    File.write(@filename, @boards.to_json)
  end

  def show_checklist(id, board)
    card = fetch_card(id, board)
    action = ""
    until action == "back"
      
      print_card(card)

      action, id = menu(["Checklist options: ", ""],
        [["add", "toggle INDEX", "delete INDEX"], ["back"]])

      case action
      when "add" then add_checklist(card)
      when "toggle" then toggle_check(card, id)
      when "delete" then delete_checklist(card, id)
      else
        puts "Invalid action" unless action == "back"
      end
    end
  end

  def fetch_card(id, board)
    board.lists.each do |list|
      card = list.cards.find { |c| c.id == id}
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

  def add_checklist(card)
    print "Title: "
    title = gets.chomp
    card.checklist.push({ title: title, completed: false })
    save
  end

  def toggle_check(card, id)
    card.checklist[id - 1][:completed] = !card.checklist[id - 1][:completed]
    save
  end

  def delete_checklist(card, id)
    card.checklist.delete(card.checklist[id - 1])
    save
  end

  def exit
    puts "#" * 36
    puts "##{' ' * 3}Thanks for using CLIn Boards#{' ' * 3}#"
    puts "#" * 36
  end

end

filename = ARGV.shift
ARGV.clear

filename = "store.json" if filename.nil?

app = ClinBoards.new(filename)
app.start
