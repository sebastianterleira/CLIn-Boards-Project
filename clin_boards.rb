require "terminal-table"

class ClinBoards
  def initialize(filename)
    @filename = filename
  end

  def start
    welcome_message
    action = ""
    until action == "exit"
      print_table(list:{}, title: "CLIn Boards", headings: ["ID", "Name", "Description", "List(#cards)"])
      
      action, id = menu(["create", "show ID", "update ID", "delete ID", "exit" ]) 

      case action
      when "create" then puts "Create Board" #create_playlist
      when "show" then puts "Show Board #{id}"  #update_playlist(id)
      when "update" then puts "Update Board #{id}"  #show_playlist(id)
      when "delete" then puts "Delete Board #{id}"  #delete_playlist(id)
      when "exit" then puts "Goodbye!"
      else
        puts "Invalid action"
      end
    end
    puts action
  end

  def welcome_message
    puts "#" * 36
    puts "##{' ' * 6}Welcome to CLIn Boards#{' ' * 6}#"
    puts "#" * 36
  end

  def menu(options)
    puts "Board options: #{options.join(" | ")}"
    print "> "
    action, id = gets.chomp.split #=> "show 1" ~> ["show", "1"]
    [action, id.to_i] # return implicito ~> ["show", 1]
  end

  def print_table(list:, title:, headings:)
    table = Terminal::Table.new
    table.title = title
    table.headings = headings
    #table.rows = list.map(&:details)
    puts table
  end

end

# get the command-line arguments if neccesary
filename = ARGV.shift
ARGV.clear

filename = "store.json" if filename.nil?

app = ClinBoards.new(filename)
app.start
