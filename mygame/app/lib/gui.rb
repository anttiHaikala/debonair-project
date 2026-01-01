class GUI

  def self.initialize_state args

    # general
    @@input_cooldown = 0
    @@menu_cooldown = 0

    # special fx
    @@color_flash = nil

    # hero movement
    @@moving_frames = 0
    @@strafing = false
    @@auto_move = nil
    @@hero_locked = false
    @@just_used_staircase = true
    @@standing_still_frames = 0

    # look mode
    @@look_mode_index = nil
    @@look_mode_cooldown = 0
    @@look_mode_frames = nil
    @@look_mode_x = nil
    @@look_mode_y = nil

    # behaviours that include caching
    @@tiles_observed = false
  end

  def self.mark_tiles_stale
    @@tiles_observed = false
  end

  def self.standing_still_frames
    return @@standing_still_frames
  end

  def self.moving_frames
    return @@moving_frames
  end

  def self.input_cooldown
    return @@input_cooldown
  end

  def self.add_input_cooldown frames
    @@input_cooldown += frames
  end

  def self.hero_locked
    return @@hero_locked
  end

  def self.staircase_animation args
    duration_in_frames = 100
    cutoff = 50
    @@staircase_animation_frame ||= 0
    if @@staircase_animation_frame == 0
      SoundFX.play_sound(:staircase, args)
    end
    @@staircase_animation_frame += 1
    if @@staircase_animation_frame < cutoff
      alpha = @@staircase_animation_frame.to_f / cutoff.to_f
    else
      alpha = 1.0 - (@@staircase_animation_frame.to_f - cutoff.to_f) / (duration_in_frames.to_f - cutoff.to_f)
    end
    alpha = (alpha * 255).to_i.clamp(0, 255)
    args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 0, g: 0, b: 0, a: alpha, blendmode_enum: 1 }
    if @@staircase_animation_frame > cutoff && args.state.staircase
      # actually change level now
      old_level = args.state.dungeon.levels[args.state.current_depth]
      old_level.entities.delete(args.state.hero)
      new_depth = args.state.hero.depth + (args.state.staircase == :down ? 1 : -1)
      args.state.hero.set_depth(new_depth, args)
      args.state.current_depth = args.state.hero.depth
      args.state.staircase = nil
      @@tiles_observed = false
      new_level = args.state.dungeon.levels[args.state.current_depth]
      new_level.entities << args.state.hero
      Lighting.mark_lighting_stale
    end
    if @@staircase_animation_frame >= duration_in_frames
      args.state.scene = :gameplay
      @@staircase_animation_frame = 0
      HUD.output_message args, "You enter level #{args.state.current_depth + 1} of the dungeon."
      GUI.mark_tiles_stale
      Lighting.mark_lighting_stale
    end
  end

  def self.draw_effects args
    level = Utils.level(args)
    return unless level
    tile_size = Utils.tile_size(args)
    x_offset = Utils.offset_x(args)
    y_offset = Utils.offset_y(args)
    viewport = Utils.tile_viewport(args)
    level.effects.each do |effect|
      visible = Tile.is_tile_visible?(effect.x, effect.y, args)
      hsl = effect.color
      rgb = Color::hsl_to_rgb(hsl[0], hsl[1], hsl[2])
      color = { r: rgb[:r], g: rgb[:g], b: rgb[:b] }
      char = effect.c
      next unless visible
      # check if within viewport
      if effect.x < viewport[0] || effect.x > viewport[2] || effect.y < viewport[1] || effect.y > viewport[3]
        next
      end
      args.outputs.primitives << {
        x: x_offset + effect.x * tile_size,
        y: y_offset + effect.y * tile_size,
        w: tile_size,
        h: tile_size,
        path: "sprites/sm16px.png",
        tile_x: char[0]*16,
        tile_y: char[1]*16,
        tile_w: 16,
        tile_h: 16,
        r: color[:r],
        g: color[:g],
        b: color[:b],
      }
    end
  end

  def self.handle_changing_facing args
    if !args.inputs.keyboard.key_held.command && !args.inputs.controller_one.key_held.l2
      return false
    end
    #printf "Changing facing direction based on input\n"
    hero = args.state.hero
    original_face = hero.facing
    new_face = nil
    if args.inputs.up
      new_face = :north
    elsif args.inputs.down
      new_face = :south
    elsif args.inputs.left
      new_face = :west
    elsif args.inputs.right
      new_face = :east
    else
      return false
    end
    if original_face != new_face
      hero.facing = new_face      
      HUD.output_message args, "You are now facing #{new_face.to_s}."
      args.state.kronos.spend_time(hero, hero.walking_speed * 0.20, args)
      GUI.mark_tiles_stale
      Lighting.mark_lighting_stale
      hero.detect_traps args if hero == args.state.hero
      hero.detect_secret_doors args if hero == args.state.hero
      self.add_input_cooldown 20
      return true
    else
      return false # already facing there
    end
  end

  def self.handle_input args
    $input_frames ||= 0
    $input_frames += 1

    if args.state.hero.perished && args.state.scene == :gameplay
      if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.a
        args.state.scene = :game_over
      end
      return
    end
    if args.inputs.keyboard.key_held.alt || args.inputs.controller_one.key_held.l1
      @@strafing = true
    else
      @@strafing = false
    end

    if @@inspector_active
      GUI.handle_inspector_input args
      return
    end

    if args.controller_one.key_held.r2 || args.inputs.keyboard.key_held.tab
      # look mode
      self.activate_look_mode args
      self.handle_look_mode(args)
      return
    else 
      unless @@inspector_active
        self.deactivate_look_mode args
        @@look_mode_index = nil
        @@look_mode_x = nil
        @@look_mode_y = nil
      end
    end
    # debug inputs
    if args.inputs.controller_one.key_down.r3 || args.inputs.keyboard.key_down.escape
      $debug = !$debug
      HUD.output_message args, "Debug mode #{$debug ? 'enabled' : 'disabled'}."
    end
    if $debug
      if args.inputs.keyboard.key_down.m || args.controller_one.key_down.x
        Tile.auto_map_whole_level(args)
      end
      if args.inputs.keyboard.key_down.t || args.controller_one.key_down.y
        args.state.hero.teleport(args)
      end
      if args.inputs.keyboard.key_down.l || args.controller_one.key_down.r3
        Debug.press_l(args)
        return
      end
      if args.inputs.keyboard.key_down.r
        $display_room_debug = !$display_room_debug
      end
      if args.inputs.keyboard.key_down.f
        $display_los_debug = !$display_los_debug
      end
    end
    # inventory management can happen in parallel
    self.handle_inventory_input args
    return if self.handle_changing_facing args # if the facign change was successful we are done
    unless GUI.is_hero_locked? # already moving
      # add a slight cooldown to prevent rapid movement
      @@input_cooldown ||= 0
      if @@input_cooldown > 0
        @@input_cooldown -= 1
        @@moving_frames += 1
      else
      # player movement
        if args.inputs.up && !args.controller_one.key_held.r1 && !args.controller_one.key_held.b && !args.keyboard.key_held.shift
          GUI.move_player(0, 1, args)
        elsif args.inputs.down && !args.controller_one.key_held.r1 && !args.controller_one.key_held.b && !args.keyboard.key_held.shift
          GUI.move_player(0, -1, args)
        elsif args.inputs.left && !args.controller_one.key_held.r1 && !args.controller_one.key_held.b && !args.keyboard.key_held.shift 
          GUI.move_player(-1, 0, args)
        elsif args.inputs.right && !args.controller_one.key_held.r1 && !args.controller_one.key_held.b && !args.keyboard.key_held.shift
          GUI.move_player(1, 0, args)
        elsif @@auto_move
          dx, dy = @@auto_move
          moved = GUI.move_player(dx, dy, args)
          unless moved
            @@auto_move = nil # stop auto moving if blocked
          end
        else
          # standing still
          @@standing_still_frames += 1
          @@moving_frames = 0
          if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.a
            # pick up item(s) on the current tile
            # check for items
            hero = args.state.hero
            level = args.state.dungeon.levels[hero.depth]
            items_on_tile = level.items.select { |item| item.x == hero.x && item.y == hero.y }
            # if there are items:
            if items_on_tile && items_on_tile.size > 0
              items_on_tile.each do |item|
                hero.pick_up_item(item, level, args)
                return
              end
            end
            # if there is a torch on an adjacent tile, pick it up
            adjacent_tiles = [[hero.x+1, hero.y], [hero.x-1, hero.y], [hero.x, hero.y+1], [hero.x, hero.y-1]]
            adjacent_tiles.each do |tile_coords|
              tx = tile_coords[0]
              ty = tile_coords[1]
              items_on_tile = level.lights.select { |item| item.x == tx && item.y == ty && item.kind == :torch }
              if items_on_tile && items_on_tile.size > 0
                items_on_tile.each do |item|
                  torch = Item.new(:torch, :portable_light)
                  hero.carried_items << torch
                  level.lights.delete(item)
                  HUD.output_message args, "You pick up the torch."
                  SoundFX.play_sound(:torch, args)
                  return
                end
              end
            end
            # check for staircase use
            tile = level.tiles[hero.y][hero.x]
            if tile == :staircase_down || tile == :staircase_up 
              unless args.inputs.keyboard.key_held.shift || args.inputs.controller_one.key_held.b
                unless @@just_used_staircase
                  # staircase? use if one is present
                  
                  printf "Hero is using staircase on tile #{tile} x,y: #{hero.x},#{hero.y}\n"
                  if tile == :staircase_down
                    GUI.take_staircase_down(args)
                  elsif tile == :staircase_up
                    GUI.take_staircase_up(args)
                  end
                end
              end
            end
          end
          if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.a
            # rest
            args.state.hero.rest(args)
            @@input_cooldown = 8
          end
        end
      end

    else
      # hero is locked, ignore input
      @@moving_frames += 1
      @@standing_still_frames = 0
    end

    # zooming with mouse wheel or right analog
    zoom_acceleration = 0.01  
    if args.inputs.mouse.wheel
      zoom_input = args.inputs.mouse.wheel.y 
      if zoom_input > 0
        $zoom_speed += zoom_acceleration
      elsif zoom_input < 0
        $zoom_speed -= zoom_acceleration
      end
    end
    if args.inputs.controller_one.right_analog_y_perc.abs > 0.1
      zoom_input = args.inputs.controller_one.right_analog_y_perc
      if zoom_input > 0
        $zoom_speed += zoom_acceleration
      elsif zoom_input < 0
        $zoom_speed -= zoom_acceleration
      end
    end
    $zoom_speed *= 0.8 # deceleration
    if $zoom_speed.abs < 0.001
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
    start_profile(:observe_tiles, args)
    Tile.observe_tiles args unless @@tiles_observed
    end_profile(:observe_tiles, args)
    @@tiles_observed = true
    start_profile(:tile_drawing, args)
    Tile.draw_tiles args
    end_profile(:tile_drawing, args)
  end

  def self.draw_foliage args
    level = Utils.level(args)
    return unless level
    Foliage.draw(args, level)
  end

  def self.draw_entities args
    level = Utils.level(args)
    return unless level
    level.entities.each do |entity|
      telepathic_connection = false
      next unless entity.x && entity.y && entity.visual_x && entity.visual_y
      unless entity == args.state.hero
        # then check tile visibility
        visible = Tile.is_tile_visible?(entity.x, entity.y, args) && !entity.invisible?
        if args.state.hero.telepathy_range > 0
          dist_x = (entity.x - args.state.hero.x).abs
          dist_y = (entity.y - args.state.hero.y).abs
          # pythagorean distance
          dist = Math.sqrt(dist_x**2 + dist_y**2)
          if dist <= args.state.hero.telepathy_range
            telepathic_connection = true 
          end
        end
        # check fov last
        if Utils.in_hero_fov?(entity.x, entity.y, args) == false && telepathic_connection == false
          visible = false
        end
        if visible
          entity.has_been_seen = true
        end
        next unless visible || telepathic_connection
      else
        visible = true
      end
      tile_size = $tile_size * $zoom
      dungeon = args.state.dungeon
      level = dungeon.levels[args.state.current_depth]
      level_height = level.tiles.size
      level_width = level.tiles[0].size
      x_offset = $pan_x + (1280 - (level_width * tile_size)) / 2
      y_offset = $pan_y + (720 - (level_height * tile_size)) / 2
      x = entity.visual_x
      y = entity.visual_y
      alpha = 255
      if entity.invisible?
        alpha = 90
      end
      lighting = level.lighting[y][x] # 0.0 to 1.0
      hue = entity.color[0]
      saturation = entity.color[1]
      level = entity.color[2]
      level *= lighting unless telepathic_connection
      tile_x = entity.c[0]
      tile_y = entity.c[1]
      if telepathic_connection && !visible && !entity.has_been_seen
        tile_x = 9
        tile_y = 0
      end
      color = Color::hsl_to_rgb(hue, saturation, level)
      height = tile_size
      angle = 0
      y_adjustment = 0
      if entity.has_status?(:shocked)
        height = (tile_size * 0.8).to_i
        angle = 15
        y_adjustment -= (tile_size * 0.4).to_i
      end
      args.outputs.primitives << {
        x: x_offset + x * tile_size,
        y: y_offset + y * tile_size,
        w: tile_size,
        h: height,
        path: "sprites/sm16px.png",
        tile_x: tile_x*16,
        tile_y: tile_y*16,
        tile_w: 16,
        tile_h: 16,
        r: color[:r],
        g: color[:g],
        b: color[:b],
        a: alpha,
        angle: angle
      }
      if entity.feels
        entity.feels.each do |feel|
          if entity.feel_cooldown < args.state.kronos.world_time
            next
          end
          args.outputs.primitives << {
            x: x_offset + x * tile_size,
            y: y_offset + y * tile_size + y_adjustment,
            w: tile_size,
            h: tile_size,
            path: "sprites/feels/#{feel}.png",
            angle: 0
          }
        end
      end
      # draw entity facing
      facing_x = x_offset + entity.visual_x * tile_size
      facing_y = y_offset + entity.visual_y * tile_size
      facing_angle = 0
      case entity.facing
      when :east
        facing_angle = 270
        facing_x += tile_size
      when :north
        facing_angle = 0
        facing_y += tile_size
      when :west
        facing_x -= tile_size
        facing_angle = 90
      when :south
        facing_y -= tile_size
        facing_angle = 180
      end
      args.outputs.primitives << {
        x: facing_x,
        y: facing_y,
        w: tile_size,
        h: tile_size,
        path: "sprites/gui/facing-arrow.png",
        angle: facing_angle,
        r: color[:r],
        g: color[:g],
        b: color[:b],
        a: alpha
      }
    end
  end

  def self.draw_background args
    args.outputs.solids << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 0, g: 0, b: 0, a: 255 }
  end

  # return false if move not possible
  def self.move_player dx, dy, args
    hero = args.state.hero
    level = args.state.dungeon.levels[hero.depth]
    if hero.has_status?(:shocked)
      HUD.output_message args, "You attempt to move but cannot due to shock!"
      args.state.kronos.spend_time(hero, hero.walking_speed * 4, args)
      return true
    end
    if hero.exhaustion >= 1.0
      HUD.output_message args, "You are too exhausted to move!"
      hero.rest(args)
      return true
    end
    if hero.has_status?(:confused)
      if args.state.rng.d6 <= 4
        # randomize direction
        directions = [[0,1],[0,-1],[-1,0],[1,0]]
        random_direction = directions.sample
        dx = random_direction[0]
        dy = random_direction[1]
      end
    end
    if args.inputs.keyboard.key_held.z || args.inputs.controller_one.key_held.r1
      @@auto_move = [dx, dy] # move until blocked
    end
    @@standing_still_frames = 0
    @@moving_frames += 1
    # auto move end check
    if @@auto_move != [dx, dy]
      @@auto_move = nil
    end
    # boundary checks
    if hero.x + dx < 0 || hero.y + dy < 0
      @@auto_move = nil
      return false
    end
    if hero.x + dx >= args.state.dungeon.levels[hero.depth].tiles[0].size ||
       hero.y + dy >= args.state.dungeon.levels[hero.depth].tiles.size
      @@auto_move = nil
      return false
    end
    if Furniture.blocks_movement?(hero.x + dx, hero.y + dy, Utils.level(args), args)
      @@auto_move = nil
      # check if there is an openable door
      furniture = Furniture.furniture_at(hero.x + dx, hero.y + dy, Utils.level(args), args)
      if furniture && (furniture.kind == :door || furniture.kind == :secret_door) && furniture.openness == 0
        unless furniture.hidden?
          affordance = Affordance.new(Utils.level(args), hero.x + dx, hero.y + dy, :open_door, nil, nil)
          affordance.execute(hero, args)
          self.add_input_cooldown 20
          return true
        end
      end
      return false
    end
    unless level.is_walkable?(hero.x + dx, hero.y + dy, args)
      @@auto_move = nil
      # add input cooldown
      self.add_input_cooldown 20
      return false
    end
    if Tile.occupied?(hero.x + dx, hero.y + dy, args)
      if @@auto_move
        @@auto_move = nil # stop auto moving if blocked
        return false
      end
      # determine if there is combat or not
      npc = args.state.dungeon.levels[hero.depth].entity_at(hero.x + dx, hero.y + dy)
      if hero.is_hostile_to?(npc) 
        # check that the direction button was pressed, not just held
        if args.inputs.keyboard.key_down.up || args.inputs.keyboard.key_down.down || args.inputs.keyboard.key_down.left || args.inputs.keyboard.key_down.right || args.inputs.controller_one.key_down.dpad_up || args.inputs.controller_one.key_down.dpad_down || args.inputs.controller_one.key_down.dpad_left || args.inputs.controller_one.key_down.dpad_right
          Combat.resolve_attack(hero, npc, args)
          hero.apply_new_facing(Utils.direction_from_delta(dx, dy))
          self.add_input_cooldown 20
          args.state.kronos.spend_time(hero, hero.walking_speed, args) # todo fix speed depending on action
          # mark lighting stale
          Lighting.mark_lighting_stale
          self.mark_tiles_stale
          HUD.mark_minimap_stale
          return true
        else
          return false
        end
      else
        if npc.is_hostile_to?(hero)
          HUD.output_message args, "You bump into the #{npc.name}!"
        else
          # swap places
          HUD.output_message args, "You trade places with the #{npc.name}."
          npc.x = hero.x
          npc.y = hero.y
          hero.x += dx
          hero.y += dy
          args.state.kronos.spend_time(hero, hero.walking_speed, args)
          Lighting.mark_lighting_stale
          return true
        end
      end

    end
    # we are cleared to move
    GUI.lock_hero
    Tile.enter(hero, hero.x + dx, hero.y + dy, args)
    unless @@strafing
      hero.apply_new_facing(Utils.direction_from_delta(dx, dy))
    end
    hero.apply_walking_exhaustion(args)
    return true
  end

  def self.update_entity_animations args
    animation_speed = 0.2 # tiles per frame
    level = args.state.dungeon.levels[args.state.current_depth]
    return unless level
    level.entities.each do |entity|
      next unless entity.x && entity.y && entity.visual_x && entity.visual_y
      if entity.visual_x < entity.x
        entity.visual_x += animation_speed
        if entity.visual_x > entity.x
          entity.visual_x = entity.x
        end
      elsif entity.visual_x > entity.x
        entity.visual_x -= animation_speed
        if entity.visual_x < entity.x
          entity.visual_x = entity.x
        end
      end
      if entity.visual_y < entity.y
        entity.visual_y += animation_speed
        if entity.visual_y > entity.y
          entity.visual_y = entity.y
        end
      elsif entity.visual_y > entity.y
        entity.visual_y -= animation_speed
        if entity.visual_y < entity.y
          entity.visual_y = entity.y
        end
      end
    end
    # check if hero has reached target
    hero = args.state.hero
    if hero.visual_x == hero.x && hero.visual_y == hero.y
      GUI.unlock_hero(args) if GUI.is_hero_locked?
    end
  end  

  def self.is_hero_locked?
    return @@hero_locked
  end

  def self.lock_hero
    @@hero_locked = true
    @@just_used_staircase = false
    # input cooldown depends on moving frames
    if @@moving_frames > 200
      @@input_cooldown = 2 # frames
    elsif @@moving_frames > 60
      @@input_cooldown = 4 # frames
    elsif @@moving_frames > 20
      @@input_cooldown = 4 # frames
    else
      @@input_cooldown = 8 # frames
    end    
  end

  def self.unlock_hero(args)
    @@hero_locked = false
    @@tiles_observed = false
    x = args.state.hero.x
    y = args.state.hero.y
    @@look_mode_x = x
    @@look_mode_y = y
    Lighting.mark_lighting_stale
    HUD.mark_minimap_stale
  end

  def self.pan_to_player args
    hero = args.state.hero
    tile_size = $tile_size * $zoom
    dungeon = args.state.dungeon
    level = dungeon.levels[args.state.current_depth]
    level_height = level.tiles.size
    level_width = level.tiles[0].size
    x_offset = $pan_x + ($gui_width - (level_width * tile_size)) / 2
    y_offset = $pan_y + ($gui_height - (level_height * tile_size)) / 2
    x = hero.x
    y = hero.y
    hero_center_x = x_offset + x * tile_size + tile_size / 2
    hero_center_y = y_offset + y * tile_size + tile_size / 2

    pan_speed = $auto_pan_speed
    if $zoom_speed.abs > 0
      pan_speed *= 6 # faster panning when zooming
    end

    if hero_center_x < $gui_width * $auto_pan_margin || hero_center_x > $gui_width * (1 - $auto_pan_margin)
      # let's set a horizontal pan target
      # desired x offset to center hero
      desired_x_offset = $gui_width / 2 - (x * tile_size + tile_size / 2)
      $pan_x += (desired_x_offset - x_offset) * pan_speed
    end

    if hero_center_y < $gui_height * $auto_pan_margin || hero_center_y > $gui_height * (1 - $auto_pan_margin)
      # let's set a vertical pan target
      # desired y offset to center hero
      desired_y_offset = $gui_height / 2 - (y * tile_size + tile_size / 2)
      $pan_y += (desired_y_offset - y_offset) * pan_speed
    end
    
  end

  def self.auto_move
    return @@auto_move
  end

  def self.flash_screen color, args
    @@color_flash = [color, 25, 0] # color and duration in frames
  end

  def self.update_screen_flash args
    return unless @@color_flash
    color_flash = @@color_flash
    duration = color_flash[1]
    frames_used = color_flash[2]
    frames_used += 1
    if frames_used >= duration
      @@color_flash = nil
    else
      @@color_flash[2] = frames_used
    end
    alpha = ((duration - frames_used).to_f / duration.to_f * 100.0).to_i.clamp(0, 100)
    if color_flash[0] == :red
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 200, g: 0, b: 0, a: alpha, blendmode_enum: 1 }
    end
    if color_flash[0] == :purple
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 150, g: 0, b: 150, a: alpha, blendmode_enum: 1 }
      GUI.flash_screen(:purple, args)
    end
  end

  def self.draw_furniture args
    level = Utils.level(args)
    return unless level
    tile_size = Utils.tile_size(args)
    x_offset = Utils.offset_x(args)
    y_offset = Utils.offset_y(args)
    viewport = Utils.tile_viewport(args)
    level.furniture.each do |furniture|
      # check if within viewport
      if furniture.x < viewport[0] || furniture.x > viewport[2] || furniture.y < viewport[1] || furniture.y > viewport[3]
        next
      end
      # check visibility and memory
      visible = Tile.is_tile_visible?(furniture.x, furniture.y, args)
      remembered = furniture.seen_by_hero
      if visible && !remembered && furniture.kind != :secret_door
        furniture.seen_by_hero = true
      end
      next if furniture.kind == :secret_door && !remembered
      next unless visible || remembered
      saturation_modifier = visible ? 1.0 : 0.7
      lighting = level.lighting[furniture.y][furniture.x] # 0.0 to 1.0
      if visible
        lightness_modifier = 1.0 - (1.0 * (1.0 - lighting.clamp(0.0, 1.0)))
      else
        lightness_modifier = 0.3
      end
      hue = furniture.color[0]
      saturation = furniture.color[1] * saturation_modifier
      brightness = furniture.color[2] * lightness_modifier
      color = Color::hsl_to_rgb(hue, saturation, brightness)
      x_offset_adjustment = 0
      y_offset_adjustment = 0
      angle = furniture.rotation
      if (furniture.kind == :door || furniture.kind == :secret_door) && furniture.openness > 0
        # rotate door to open it
        angle = furniture.rotation + 90
        if furniture.rotation == 0
          x_offset_adjustment = -(tile_size / 2) * furniture.openness  
          y_offset_adjustment = (tile_size / 2) * furniture.openness
        end
        if furniture.rotation == 90
          x_offset_adjustment = -(tile_size / 2) * furniture.openness  
          y_offset_adjustment = (tile_size / 2) * furniture.openness
        end
      end
      #printf "adjustments for open door: angle: #{angle} x: #{x_offset_adjustment}, y: #{y_offset_adjustment}\n"
      args.outputs.primitives << {
        x: x_offset + x_offset_adjustment.to_i + furniture.x * tile_size,
        y: y_offset + y_offset_adjustment.to_i + furniture.y * tile_size,
        w: tile_size,
        h: tile_size,
        path: "sprites/furniture/#{furniture.kind.gsub('secret_','')}.png",
        angle: angle,
        r: color[:r],
        g: color[:g],
        b: color[:b]
      }
    end
  end

  def self.draw_corridor_debug args
    return unless $debug
    level = Utils.level(args)
    return unless level
    tile_size = Utils.tile_size(args)
    x_offset = Utils.offset_x(args)
    y_offset = Utils.offset_y(args)
    level.corridors.each do |corridor|
      corridor_length = corridor.steps.size
      color = corridor.color
      offset_seed = (corridor.x1 + corridor.y1 + corridor.x2 + corridor.y2) % 10
      c_offset = offset_seed * 0.1
      # then draw the steps
      step_count = 0
      corridor.steps.each do |step|
        step_count += 1
        args.outputs.primitives << {
          x: x_offset + (step[:x] + 0.1) * tile_size,
          y: y_offset + (step[:y] + 0.1) * tile_size,
          w: tile_size*0.8,
          h: tile_size*0.8,
          path: :solid,
          r: color[:r],
          g: color[:g],
          b: color[:b],
          a: 80
        }
        # mark step number 
        args.outputs.primitives << {  
          x: x_offset + (step[:x] + 0.4) * tile_size,
          y: y_offset + (step[:y] + 0.9) * tile_size,
          w: tile_size,
          h: tile_size, 
          text: "#{step_count}",
          size_enum: 0,
          r: color[:r],
          g: color[:g],
          b: color[:b],
          a: 200
        }
        if step_count == (corridor_length / 2).floor
          # mark midpoint
          args.outputs.primitives << {  
            x: x_offset + (step[:x] + 0.2) * tile_size,
            y: y_offset + (step[:y] + 0.2) * tile_size,
            w: tile_size,
            h: tile_size, 
            text: "#{corridor.name} midpoint",
            size_enum: 0,
            r: color[:r],
            g: color[:g],
            b: color[:b],
            a: 200
          }
        end
      end
      # mark corridor start
      args.outputs.primitives << {
        x: x_offset + (corridor.x1 + c_offset) * tile_size,
        y: y_offset + (corridor.y1 + c_offset) * tile_size,
        w: tile_size,
        h: tile_size, 
        path: :text,
        text: "#{corridor.name} start",
        size_enum: 1,
        alignment_enum: 2,
        r: color[:r],
        g: color[:g],
        b: color[:b],
        a: 200
      }
      # mark corridor end
      args.outputs.primitives << {
        x: x_offset + (corridor.x2 + c_offset) * tile_size,
        y: y_offset + (corridor.y2 + c_offset) * tile_size,
        w: tile_size,
        h: tile_size, 
        path: :text,
        text: "#{corridor.name} end",
        alignment_enum: 0,
        size_enum: 1,
        r: color[:r],
        g: color[:g],
        b: color[:b],
        a: 200
      }

    end
    
  end

  def self.draw_room_debug args
    return unless $debug
    level = Utils.level(args)
    return unless level
    tile_size = Utils.tile_size(args)
    x_offset = Utils.offset_x(args)
    y_offset = Utils.offset_y(args)
    level.rooms.each do |room|
      color = room.color
      args.outputs.primitives << {
        x: x_offset + room.x * tile_size,
        y: y_offset + room.y * tile_size,
        w: room.w * tile_size,
        h: room.h * tile_size, 
        path: :solid,
        r: color[:r],
        g: color[:g],
        b: color[:b],
        a: 80
      }
      # output room details
      args.outputs.primitives << {
        x: x_offset + (room.x + 0.2) * tile_size,
        y: y_offset + (room.y + room.h - 0.3) * tile_size,
        w: tile_size,
        h: tile_size, 
        text: "#{room.name} (#{room.w}x#{room.h})",
        size_enum: 0,
        r: color[:r],
        g: color[:g],
        b: color[:b],
        a: 200
      }
    end
  end

  def self.draw_los_debug args
    return unless $debug
    level = Utils.level(args)
    return unless level
    tile_size = Utils.tile_size(args)
    x_offset = Utils.offset_x(args)
    y_offset = Utils.offset_y(args)
    tile_viewport = Utils.tile_viewport args
    x_start = tile_viewport[0]
    y_start = tile_viewport[1]
    x_end = tile_viewport[2]
    y_end = tile_viewport[3]
    depth = level.depth
    for x in (x_start..x_end)
      for y in (y_start..y_end)
        printf "Checking LOS for tile #{x},#{y}\n"
        visibility = Tile.visibility_at(x, y, depth, args)
        if visibility == true
          args.outputs.primitives << {
            x: x_offset + (x+0.5) * tile_size,
            y: y_offset + (y+0.7) * tile_size,
            w: tile_size,
            h: tile_size,
            text: "V",
            size_enum: 1,
            r: 0,
            g: 255,
            b: 0,
            a: 100
          }
        else
          args.outputs.primitives << {
            x: x_offset + (x+0.5) * tile_size,
            y: y_offset + (y+0.7) * tile_size,
            w: tile_size,
            h: tile_size,
            text: "X",
            size_enum: 1,
            r: 255,
            g: 0,
            b: 0,
            a: 100
          }
        end
        # also print lighting level
        lighting = level.lighting[y][x]
        lighting_value = (lighting * 100).to_i
        args.outputs.primitives << {
          x: x_offset + (x+0.6) * tile_size,
          y: y_offset + (y+0.3) * tile_size,
          w: tile_size,
          h: tile_size,
          text: "#{lighting_value}",
          size_enum: 0,
          alignment_enum: 1,
          r: 255,
          g: 255,
          b: 0,
          a: 100
        }
      end
    end
  end

  def self.draw_npc_debug args
    return unless $debug
    level = Utils.level(args)
    return unless level
    tile_size = Utils.tile_size(args)
    x_offset = Utils.offset_x(args)
    y_offset = Utils.offset_y(args)
    level.entities.each do |entity|
      next unless entity.x && entity.y
      args.outputs.primitives << {
        x: x_offset + (entity.x + 0.1) * tile_size,
        y: y_offset + (entity.y + 0.7) * tile_size,
        w: tile_size,
        h: tile_size,
        text: "#{entity.last_behaviour} #{entity.facing}",
        size_enum: 0,
        r: 255,
        g: 200,
        b: 0,
        a: 200
      }
    end
  end 

  def self.take_staircase_down args
    args.state.staircase = :down
    args.state.scene = :staircase
    @@just_used_staircase = true
    @@staircase_animation_frame = 0    
  end

  def self.take_staircase_up args
    hero = args.state.hero
    if hero.depth > 0
      args.state.staircase = :up
      args.state.scene = :staircase
      @@just_used_staircase = true
      @@staircase_animation_frame = 0
    else
      args.state.scene = :game_over
    end
  end

end