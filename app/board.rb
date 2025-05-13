class Board
  attr_gtk

  def tick args
    self.args = args
    defaults
    calc
  end

  def defaults
    return if state.grid

    state.grid = {
      cell_w: 1,
      cell_h: 1,
      w: Layout::rect(w: 1).w,
      h: Layout::rect(h: 1).h
    }

    new_squares = []
    (1..6).each do |y|
      (9..14).each do |x|
        new_squares << cell_prefab(
          row: y,
          col: x,
          w: state.grid.cell_w,
          h: state.grid.cell_h
        )
      end
    end
    state.grid.cells = new_squares

    state.selected_cell ||= state.grid.cells.first
    state.selection_point ||= state.selected_cell.rect.center
    state.input_debounce  ||= 0
  end

  def cell_prefab row:, col:, w:, h:;
    rect = Layout::rect(row: row, col: col, w: w, h: h)
    {
      row: row,
      col: col,
      rect: rect,
      primitives: [
        rect.merge(primitive_marker: :border),
      ]
    }
  end

  def calc_directional_input
    return if state.input_debounce.elapsed_time < 10
    return if !inputs.directional_vector
    state.input_debounce = Kernel.tick_count

    state.selected_cell = Geometry::rect_navigate(
      rect: state.selected_cell,
      rects: state.grid.cells,
      left_right: inputs.left_right,
      up_down: inputs.up_down,
      wrap_x: true,
      wrap_y: true,
      using: lambda { |e| e.rect }
    )
  end

  def calc_mouse_input
    return if !inputs.mouse.moved
    hovered_cell = state.grid.cells.find { |b| Geometry::intersect_rect? inputs.mouse, b.rect }
    if hovered_cell
      state.selected_cell = hovered_cell
    end
  end

  def calc
    target_point_x = state.selected_cell.rect.x + (state.selected_cell.rect.w / 2)
    target_point_y = state.selected_cell.rect.y + (state.selected_cell.rect.h / 2)
    state.selection_point.x = state.selection_point.x.lerp(target_point_x, 0.25)
    state.selection_point.y = state.selection_point.y.lerp(target_point_y, 0.25)
    calc_directional_input
    calc_mouse_input
  end

  def render
    out = []
    out <<  state.selection_point.merge(w: state.grid.cell_w + 8,
                                        h: state.grid.cell_h + 8,
                                        a: 128,
                                        r: 0,
                                        g: 200,
                                        b: 100,
                                        path: :solid,
                                        anchor_x: 0.5,
                                        anchor_y: 0.5)

    out << state.grid.cells.map(&:primitives)
  end
end
