
$zoom = 0.7
$pan_x = 0.0
$pan_y = 0.0
$zoom_speed = 0.0
$max_zoom = 3.0
$min_zoom = 0.2

class GUI

  def self.handle_input args

    # zooming with mouse wheel
    zoom_acceleration = 0.2
    if args.inputs.mouse.wheel
      zoom_input = args.inputs.mouse.wheel.y
      if zoom_input > 0
        $zoom_speed += zoom_acceleration
      elsif zoom_input < 0
        $zoom_speed -= zoom_acceleration
      end
    end
    $zoom_speed *= 0.8 # deceleration
    if $zoom_speed.abs < 0.1
      $zoom_speed = 0
    end
    zoom_delta = $zoom_speed
    requested_zoom = $zoom + zoom_delta
    $zoom = requested_zoom.clamp($min_zoom, $max_zoom)

    # panning with touch/mouse drag
    if args.inputs.mouse.buffered_held && args.inputs.mouse.moved
        delta_x = args.inputs.mouse.previous_x - args.inputs.mouse.x
        delta_y = args.inputs.mouse.previous_y - args.inputs.mouse.y
        $pan_x -= delta_x
        $pan_y -= delta_y
    end
  end

  def self.draw_tiles args
    Tile.draw_tiles args
  end

  def self.draw_entities args
    if args.state.entities.nil?
      return
    end
    args.state.entities.each do |entity|
      if entity.level == args.state.current_level
        tile_size = 40 * $zoom
        dungeon = args.state.dungeon
        level = dungeon.levels[args.state.current_level]
        level_height = dungeon.levels[args.state.current_level].tiles.size
        level_width = dungeon.levels[args.state.current_level].tiles[0].size
        x_offset = $pan_x + (1280 - (level_width * tile_size)) / 2
        y_offset = $pan_y + (720 - (level_height * tile_size)) / 2
        x = entity.x
        y = entity.y
        args.outputs.sprites << {
          x: x_offset + x * tile_size,
          y: y_offset + y * tile_size,
          w: tile_size,
          h: tile_size,
          path: "mygame/sprites/simple-mood-16x16.png",
          tile_x: 3*16,
          tile_y: 3*16,
          tile_w: 16,
          tile_h: 16
        }
      end
    end
  end

  def self.draw_hud args

  end

  def self.draw_background args
    args.outputs.solids << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 0, g: 0, b: 0, a: 255 }
  end

  
end