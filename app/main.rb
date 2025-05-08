require 'app/menu.rb'


def init args
  args.state.game = Menu.new()
end

def tick args
  if args.tick_count == 0
    init args
  end

  args.state.game.args = args
  args.state.game.tick

  if args.state.selected_button and args.inputs.mouse.click
    puts args.state.selected_button
  end
end
