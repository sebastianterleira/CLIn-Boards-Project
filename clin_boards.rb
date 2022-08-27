require "terminal-table"
require "json"
require_relative "boards"
require_relative "cards"
require_relative "lists"

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
      when "exit" then puts "Goodbye!"
      else
        puts "Invalid action"
      end
    end
  end

  private

  def create_board(boards)
    board_hash = board_form
    new_board = Boards.new(**board_hash)
    @boards.push(new_board)
    File.write(@filename, boards.to_json)
    p new_board
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
      when "create-list" then create_list(board)
      when "update-list" then puts "update-list! #{arg}"
      when "delete-list" then puts "Udelete-list! #{arg}"
      when "create-card" then create_card(board)
      when "checklist" then puts "create-card! #{arg}"
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

  def list_form
    print "Name: "
    name = gets.chomp
    { name: name }
  end

    def create_list(board)
      list_hash = list_form
      new_list = Lists.new(**list_hash)
      board.lists.push(new_list)
      File.write(@filename, @boards.to_json)
    end

    def list_form(board)
      puts "Select a list: "
      list_menu = []
      board.lists.each do |list| 
        list_menu.push(list.name)
      end
      puts "#{list_menu.join(" | ")}"
      print "> "
      input = gets.chomp
    end

  def cards_form(board)
    print "Tittle: "
    title = gets.chomp
    print "Members: "
    menbers = gets.chomp.split(",").map(&:strip)
    print "Labels: "
    labels = gets.chomp.split(",").map(&:strip)
    print "Due Date:"
    due_date = gets.chomp
    { title: title, members: menbers, labels: labels, due_date: due_date }
  end

  def create_card(board)
    input = list_form(board)
    card_hash = cards_form(board)
    list = find_list(input, board)
    new_card = Cards.new(**card_hash)
    list.cards.push(new_card)
    File.write(@filename, @boards.to_json)
  end

  def find_card(id)
    @boards.find { |e| e.id==id}
  end

  def find_list(list_name, board)
    board.lists.find {|l| l.name == list_name}
  end

  def save
    File.write(@filename, @boards.to_json)
  end
end

filename = ARGV.shift
ARGV.clear

filename = "store.json" if filename.nil?

app = ClinBoards.new(filename)
app.start


# <Boards:0x00007ff67e621840 
#   @id=1, 
#   @name="Extended - CLIn Boards", 
#   @description="Task management for the last extended", 
#   @lists=[
#     <Lists:0x00007ff67e621728 
#       @id=1, 
#       @name="Todo", 
#       @cards=[
#         <Cards:0x00007ff67e621610 
#           @id=1, 
#           @title="Check terminal-table gem", 
#           @members=["Diego", "Deyvi", "Wences"], 
#           @labels=["investigate"], 
#           @due_date="2020-11-19", 
#           @checklist=[
#             {:title=>"Add gem to gemfile", :completed=>true}, 
#             {:title=>"Make an example and share with the team", :completed=>false}, 
#             {:title=>"Ask if this feature is mandatory", :completed=>true}
#           ]
#         >,