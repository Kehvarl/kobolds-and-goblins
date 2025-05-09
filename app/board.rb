class Board
  attr_gtk

  def tick
    defaults
    calc
    render
  end

  def defaults
    state.space_pressed_at ||= 0
  end

  def calc
    if inputs.keyboard.key_down.space
      state.space_pressed_at = Kernel.tick_count
    end
  end

  def render
    if state.space_pressed_at == 0
      outputs.labels << { x: 100, y: 100,
                          text: "press space" }
    else
      outputs.labels << { x: 100, y: 100,
                          text: "space was pressed at: #{state.space_pressed_at}" }
    end
  end
end
