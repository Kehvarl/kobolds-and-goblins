class Tile
  attr_sprite

  SIDES = {
    kobolds: {
      path: "sprites/kobold_priest.png",
      tile_w: 32,
      tile_h: 32,
      row: 2,
      frames: 8
    },
    goblins: {
      path: "sprites/goblin_king.png",
      tile_w: 64,
      tile_h: 64,
      row: 5,
      frames: 15
    }
  }

  def initialize(x, y, w, h, side)
    config = SIDES[side]

    @x = x
    @y = y
    @w = w
    @h = h

    @path = config[:path]
    @tile_w = config[:tile_w]
    @tile_h = config[:tile_h]
    @row = config[:row]
    @frames = config[:frames]

    @frame = 0
    @frame_delay = 5
    @tile_x = 0
    @tile_y = @tile_h * @row
  end

  def tick
    @frame_delay -= 1
    return unless @frame_delay <= 0

    @frame_delay = 5
    @frame = (@frame + 1) % @frames
    @tile_x = @tile_w * @frame
  end
end


# ./samples/09_ui_controls/02_menu_navigation/app/main.rb
class Board
  attr_gtk

  def tick args
    self.args = args
    defaults
    calc
    find_matches
    state.sprites.each{|t| t.tick}
  end

  def defaults
    return if state.grid

    state.matches = []
    state.sprites = []

    state.grid = {
      cell_w: 1,
      cell_h: 1,
      w: Layout::rect(w: 1).w,
      h: Layout::rect(h: 1).h
    }

    new_squares = []
    (1..5).each do |y|
      (9..13).each do |x|
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
      content: :empty,
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

  def find_matches
    cells = state.grid.cells

    rows = cells.group_by { |c| c[:row] }
    cols = cells.group_by { |c| c[:col] }

    matches = []

    rows.each_value do |line|
      sorted = line.sort_by { |c| c[:col] }
      matches += find_line_matches(sorted)
    end

    cols.each_value do |line|
      sorted = line.sort_by { |c| c[:row] }
      matches += find_line_matches(sorted)
    end

    diagonals_down = cells.group_by { |c| c[:row] - c[:col] }
    diagonals_down.each_value do |line|
      sorted = line.sort_by { |c| [c[:row], c[:col]] }
      matches += find_line_matches(sorted)
    end

    diagonals_up = cells.group_by { |c| c[:row] + c[:col] }
    diagonals_up.each_value do |line|
      sorted = line.sort_by { |c| [c[:row], c[:col]] }
      matches += find_line_matches(sorted)
    end

    state.matches = matches
  end

  def find_line_matches(line)
    return [] if line.empty?

    matches = []
    current = [line[0]]

    (1...line.length).each do |i|
      if line[i][:content] == current.last[:content] && line[i][:content] != :empty
        current << line[i]
      else
        matches << tag_match(current) if current.length >= 3
        current = [line[i]]
      end
    end

    matches << tag_match(current) if current.length >= 3
    return matches
  end

  def tag_match(cells)
    tag = nil
    case cells.length
      when 3
        tag = :three
      when 4
        tag = :four
      when 5
        tag = :five
      else
        tag = :longer
    end

    { tag: tag, cells: cells }
  end

  def make_ai_move(side)
    empty_cells = state.grid.cells.select { |cell| cell[:content] == :empty }
    return if empty_cells.empty?

    weighted_choices = []

    empty_cells.each do |cell|
      simulated_content = cell[:content]
      cell[:content] = side
      find_matches
      score = state.matches.count { |m| m[:cells].include?(cell) }
      weighted_choices << [cell, score]
      cell[:content] = simulated_content
    end

    best = weighted_choices.max_by { |_, score| score }

    if best && best[1] > 0
      best[0].content = side
      # goblin king 64x64
      # row 5
      # 15 frames
      m = Tile.new(x=best[0].rect.x, y=best[0].rect.y, w=best[0].rect.w, h=best[0].rect.h, side=side)
      best[0].primitives << m
      state.sprites << m
    else
      t = empty_cells.sample
      t[:content] = side
      m = Tile.new(x=t.rect.x, y=t.rect.y, w=t.rect.w, h=t.rect.h, side=side)
      t.primitives << m
      state.sprites << m
    end

    find_matches
  end

  def match_summary
    score = Hash.new { |h, k| h[k] = { three: 0, four: 0, five: 0 } }

    state.matches.each do |group|
      cells = group[:cells]
      tag   = group[:tag]
      next if cells.empty?

      side = cells.first[:content]
      next if side == :empty

      score[side][tag] += 1
    end

    score
  end

  def moves_remaining
    return state.grid.cells.select{|c| c.content == :empty}.size
  end

  def render
    out = []
    out << state.grid.cells.map(&:primitives)
    out << state.selection_point.merge(w: state.grid.cell_w + 16,
                                      h: state.grid.cell_h + 16,
                                      a: 128,
                                      r: 0,
                                      g: 200,
                                      b: 100,
                                      path: :solid,
                                      anchor_x: 0.5,
                                      anchor_y: 0.5)

    out << state.matches.map do |match|
      color =
        case match[:tag]
        when :three then { r: 255, g: 255, b: 0 }
        when :four then { r: 255, g: 128, b: 0 }
        when :five then { r: 255, g: 0,   b: 0 }
        else            { r: 128, g: 0,   b: 255 }
        end

        match[:cells].map do |cell|
          cell[:rect].merge({**color, a: 200, primitive_marker: :border})
        end
      end
  end
end
