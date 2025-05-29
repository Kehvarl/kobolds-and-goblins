require 'app/menu.rb'
require 'app/board.rb'

def init args
  args.state.gamestate = :menu
  args.state.game = Menu.new()
end

def menu_tick args
  args.state.game.tick args
  if args.state.selected_button and (args.inputs.mouse.click or args.inputs.keyboard.key_up.enter or args.inputs.keyboard.key_up.space)
    case args.state.selected_button.id
    when :new_game
      puts "Start new game"
      args.state.menu = nil
      args.state.selected_button = nil
      args.state.game = Team_Select.new()
      args.state.gamestate = :team_select
      return
    when :how_to
      puts "How To Play"
      args.state.gamestate = :how_to
    when :options
      puts "Options Menu"
    when :exit
      args.gtk.request_quit
    end
  end
  args.outputs.primitives << args.state.game.render
end

def instructions_tick args
    instruction_string = "How To Play\n\n"
    instruction_string +="Try to make a line of 5 Kobolds"

    max_character_length = 80

    instructions = String.wrapped_lines instruction_string,
                                              max_character_length

    args.outputs.labels << instructions.map_with_index do |s, i|
      {
        x: 320,
        y: 720 - 60,
        anchor_y: i,
        text: s
      }
    end
  if args.inputs.keyboard.keys[:up].size > 0
    args.state.gamestate = :menu
  end
end

def game_tick args
  args.state.game.tick args
  if args.state.selected_button and (args.inputs.mouse.click or args.inputs.keyboard.key_up.enter or args.inputs.keyboard.key_up.space)
    tile = args.state.selected_cell
    return if tile.content != :empty
    t = Tile.new(x=tile.rect.x, y=tile.rect.y, w=tile.rect.w, h=tile.rect.h,
                 side=args.state.player_side)

    tile.primitives << t
    tile.content = args.state.player_side
    args.state.sprites << t

    args.state.gamestate = :computer_move
  end

  args.outputs.primitives << args.state.game.render

  if args.state.game.moves_remaining == 0
    args.state.gamestate = :game_over
  end
end

def team_select_tick args
  args.state.game.tick args
  if args.state.selected_button and (args.inputs.mouse.click or args.inputs.keyboard.key_up.enter or args.inputs.keyboard.key_up.space)
    case args.state.selected_button.id
    when :kobolds
      args.state.player_side = :kobolds
      args.state.computer_side = :goblins
      args.state.game = Board.new()
      args.state.gamestate = :game
      return
    when :goblins
      args.state.player_side = :goblins
      args.state.computer_side = :kobolds
      args.state.game = Board.new()
      args.state.gamestate = :game
      return
    when :back
      puts "Options Menu"
      args.state.menu = nil
      args.state.selected_button = nil
      args.state.game = Menu.new()
      args.state.gamestate = :menu
      return
    else
      puts args.state.selected_button.id
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
  when :team_select
    team_select_tick args
  when :unit_menu
    puts "units"
    args.state.gamestate = :game
  when :how_to
    instructions_tick args
  when :game
    game_tick args
  when :computer_move
    args.state.game.make_ai_move args.state.computer_side
    args.state.gamestate = :game
  when :game_over
      args.outputs.primitives << args.state.game.render
      args.outputs.primitives << {x:180,y:180,w:930,h:360,r:255,g:255,b:255}.solid!
      args.outputs.primitives << {x:180,y:180,w:930,h:360,r:255,g:0,b:0}.border!
      args.outputs.primitives << {x:640, y:500, text:"Game Over", size_enum: 7, anchor_x:0.5}.label!

  end
end
