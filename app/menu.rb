  # ./samples/09_ui_controls/02_menu_navigation/app/main.rb
class Menu
  attr_gtk

  def tick args
    self.args = args
    defaults
    calc
  end

  def render
    out = []
    out << state.menu.buttons.map(&:primitives)
    out <<  state.selection_point.merge(w: state.menu.button_w + 8,
                                        h: state.menu.button_h + 8,
                                        a: 128,
                                        r: 0,
                                        g: 200,
                                        b: 100,
                                        path: :solid,
                                        anchor_x: 0.5,
                                        anchor_y: 0.5)

    out
  end

  def calc_directional_input
    return if state.input_debounce.elapsed_time < 10
    return if !inputs.directional_vector
    state.input_debounce = Kernel.tick_count

    state.selected_button = Geometry::rect_navigate(
      rect: state.selected_button,
      rects: state.menu.buttons,
      left_right: inputs.left_right,
      up_down: inputs.up_down,
      wrap_x: true,
      wrap_y: true,
      using: lambda { |e| e.rect }
    )
  end

  def calc_mouse_input
    return if !inputs.mouse.moved
    hovered_button = state.menu.buttons.find { |b| Geometry::intersect_rect? inputs.mouse, b.rect }
    if hovered_button
      state.selected_button = hovered_button
    end
  end

  def calc
    target_point_x = state.selected_button.rect.x + (state.selected_button.rect.w / 2)
    target_point_y = state.selected_button.rect.y + (state.selected_button.rect.h / 2)
    state.selection_point.x = state.selection_point.x.lerp(target_point_x, 0.25)
    state.selection_point.y = state.selection_point.y.lerp(target_point_y, 0.25)
    calc_directional_input
    calc_mouse_input
  end

  def defaults
    return if state.menu

    button_labels = [
      { id: :new_game, text: "New Game" },
      { id: :how_to, text: "How To Play" },
      { id: :options, text: "Options" },
      { id: :exit, text: "Exit" }
    ]

    state.menu = {
      button_cell_w: 8,
      button_cell_h: 1,
      button_w: Layout::rect(w: 8).w,
      button_h: Layout::rect(h: 1).h
    }

    state.menu.buttons = button_labels.each_with_index.map do |entry, i|
      menu_prefab(
        id: entry[:id],
        text: entry[:text],
        row: i+4,
        col: 8,
        w: state.menu.button_cell_w,
        h: state.menu.button_cell_h
      )
    end

    state.selected_button ||= state.menu.buttons.first
    state.selection_point ||= state.selected_button.rect.center
    state.input_debounce  ||= 0
  end

  def menu_prefab id:, text:, row:, col:, w:, h:;
    rect = Layout::rect(row: row, col: col, w: w, h: h)
    {
      id: id,
      row: row,
      col: col,
      text: text,
      rect: rect,
      primitives: [
                   rect.merge(primitive_marker: :solid, r: 128, g: 128, b: 128),
                   rect.merge(primitive_marker: :border, r: 64, g: 64, b: 64),
                   rect.center.merge(text: text, anchor_x: 0.5, anchor_y: 0.5)
                  ]
    }
  end

end

  # ./samples/09_ui_controls/02_menu_navigation/app/main.rb
class Team_Select < Menu

  def defaults
    return if state.menu

    button_labels = [
      { id: :kobolds, text: "Kobolds" },
      { id: :goblins, text: "Goblins" },
      { id: :back, text: "Back" },
    ]

    state.menu = {
      button_cell_w: 8,
      button_cell_h: 1,
      button_w: Layout::rect(w: 8).w,
      button_h: Layout::rect(h: 1).h
    }

    state.menu.buttons = button_labels.each_with_index.map do |entry, i|
      menu_prefab(
        id: entry[:id],
        text: entry[:text],
        row: i+4,
        col: 8,
        w: state.menu.button_cell_w,
        h: state.menu.button_cell_h
      )
    end

    state.selected_button ||= state.menu.buttons.first
    state.selection_point ||= state.selected_button.rect.center
    state.input_debounce  ||= 0
  end
end
