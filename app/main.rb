require 'app/menu.rb'
require 'app/board.rb'


def init args
  args.state.gamestate = :menu
  args.state.game = Menu.new()
end

def menu_tick args
  args.state.game.tick args
  if args.state.selected_button and args.inputs.mouse.click
    case args.state.selected_button.id
    when :new_game
      puts "Start new game"
      args.state.gamestate = :game
    when :how_to
      puts "How To Play"
    when :options
      puts "Options Menu"
    when :exit
      puts "Exit"
    end
  end
  args.outputs.primitives << args.state.game.render
end

def tick args
  if args.tick_count == 0
    init args
  end

  case args.state.gamestate
  when :menu
    menu_tick args
  when :game
    puts "Game..."
  end
end
