require "terminal-table"
require "json"
require_relative "boards"
require_relative "tables"

class ClinBoards
  include Tables

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

  def load_boards
    data = JSON.parse(File.read(@filename), symbolize_names: true)
    data.map { |board_hash| Boards.new(**board_hash) }
  end

  def welcome_message
    puts "#" * 36
    puts "##{' ' * 6}Welcome to CLIn Boards#{' ' * 6}#"
    puts "#" * 36
  end

  def exit
    puts "#" * 36
    puts "##{' ' * 3}Thanks for using CLIn Boards#{' ' * 3}#"
    puts "#" * 36
  end

  def create_board(boards)
    board_hash = board_form
    new_board = Boards.new(**board_hash)
    @boards.push(new_board)
    File.write(@filename, boards.to_json)
  end

  def delete_board(id)
    board_selected = find_board(id, @boards)
    @boards.delete(board_selected)
    save(@filename, @boards)
  end

  def update_board(id)
    board_selected = find_board(id, @boards)
    new_card_hash = board_form
    board_selected.update(**new_card_hash)
    save(@filename, @boards)
  end

  def show_board(id)
    board = @boards.find { |b| b.id == id }
    action = ""
    until action == "back"
      initialize_table(board)

      messages, options = grab_menu_data
      action, arg = menu(messages, options)

      case action
      when "create-list" then create_list(board)
      when "update-list" then update_list(arg, board)
      when "delete-list" then delete_list(arg, board)
      when "create-card" then create_card(board)
      when "checklist" then show_checklist(arg, board)
      when "update-card" then update_card(arg, board)
      when "delete-card" then delete_card(arg, board)
      else
        puts "Invalid action" unless action == "back"
      end
    end
  end

  def create_list(board)
    list_hash = list_form
    new_list = Lists.new(**list_hash)
    board.lists.push(new_list)
    File.write(@filename, @boards.to_json)
  end

  def update_list(list_name, board)
    list_selected = find_list(list_name.capitalize, board)
    new_name_list = list_form
    list_selected.update(**new_name_list)
    save(@filename, @boards)
  end

  def delete_list(list_name, board)
    list_selected = find_list(list_name.capitalize, board)
    board.lists.delete(list_selected)
    save(@filename, @boards)
  end

  def create_card(board)
    input = list_card(board)
    card_hash = card_details_form
    list = find_list(input.capitalize, board)
    new_card = Cards.new(**card_hash)
    list.cards.push(new_card)
    File.write(@filename, @boards.to_json)
  end

  def update_card(card_id, board)
    list_input = list_card(board)
    list_selected = find_list(list_input.capitalize, board)
    new_card_details = card_details_form
    card_selected = find_card(card_id, list_selected)
    card_selected.update(**new_card_details)
    save(@filename, @boards)
  end

  def delete_card(card_id, board)
    list_with_card = find_list_by_card_id(card_id, board)
    card_selected = find_card_by_id_without_list(card_id, board)
    list_with_card.cards.delete(card_selected)
    save(@filename, @boards)
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

  def add_checklist(card)
    print "Title: "
    title = gets.chomp
    card.checklist.push({ title: title, completed: false })
    save(@filename, @boards)
  end

  def toggle_check(card, id)
    card.checklist[id - 1][:completed] = !card.checklist[id - 1][:completed]
    save(@filename, @boards)
  end

  def delete_checklist(card, id)
    card.checklist.delete(card.checklist[id - 1])
    save(@filename, @boards)
  end
end
filename = ARGV.shift
ARGV.clear
filename = "store.json" if filename.nil?
app = ClinBoards.new(filename)
app.start
