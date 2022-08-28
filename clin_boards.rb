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
    action, *arg = gets.chomp.split
    arg = arg.join(" ")
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
      
      p arg
      case action
      when "create-list" then create_list(board)
      when "update-list" then update_list(arg,board)
      when "delete-list" then delete_list(arg,board)
      when "create-card" then create_card(board)
      when "checklist" then show_checklist(arg, board)
      when "update-card" then update_card(arg,board)
      when "delete-card" then delete_card(arg,board)
      else
        puts "Invalid action" unless action == "back"
      end
    end
  end

  def delete_board(id)
    board_selected=find_board(id)
    @boards.delete(board_selected)
    save
  end
  def update_board(id)
    board_selected=find_board(id)
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

  def find_board(id)
    @boards.find { |e| e.id==id}
  end
  def delete_list(list_name,board)
    list_selected=find_list(list_name.capitalize,board)
    board.lists.delete(list_selected)
    save
  end

    def create_list(board)
      list_hash = list_form
      new_list = Lists.new(**list_hash)
      board.lists.push(new_list)
      File.write(@filename, @boards.to_json)
    end

    def list_card(board)
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
    input = list_card(board)
    card_hash = cards_form(board)
    list = find_list(input.capitalize, board)
    new_card = Cards.new(**card_hash)
    list.cards.push(new_card)
    File.write(@filename, @boards.to_json)
  end

  def find_card(id)
    @boards.find { |e| e.id==id}
  end

  def find_list(list_name, board)
    board.lists.find {|l| l.name.capitalize == list_name}
  end

  def save
    File.write(@filename, @boards.to_json)
  end
  def update_list(list_name,board)
    list_selected=find_list(list_name.capitalize,board)
    new_name_list=list_form
    p "call inea 182"
    list_selected.update(**new_name_list)
    save
  end

  def list_form
    p "linea 190"
    print "Name: "
    name = gets.chomp
    {name: name}
  end
  def update_card(card_id,board)
    list_input=list_form
    p "call linea 196"
    list_selected=find_list(list_input,board)
    new_card_details=card_details_form
    card_selected=find_card(card_id,list_selected)
    card_selected.update(**new_card_details)
    save
  end
  def delete_card(card_id,board)
    list_with_card=find_list_by_card_id(card_id,board)
    card_selected=find_card_by_id_without_list(card_id,board)
    list_with_card.cards.delete(card_selected)
    save
  end
  def find_list_by_card_id(card_id,board)
    lists=board.lists.map do |list|
      c=list.cards.find { |c| c.id==card_id }
      return list if list.cards.include?(c)
    end
    list_with_card=""
    lists.each do |list|
      list_with_card =list unless list.nil?
    end
    list_with_card
  end
  def find_card_by_id_without_list(card_id,board)
    cards=board.lists.map do |list|
      list.cards.find { |c| c.id==card_id }
    end
    card_selected=""
    cards.each do |card|
      card_selected =card unless card.nil?
    end
    card_selected
  end
  def find_card(card_id,list)
    list.cards.find { |c| c.id==card_id }
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
    p members
    p labels
    { title: title, members:members, labels:labels, due_date: due_date }
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
