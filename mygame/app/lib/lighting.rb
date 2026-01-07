class Lighting

  @@lighting_stale = true

  def self.mark_lighting_stale
    @@lighting_stale = true
  end

  def self.light_level_at(x, y, level, args)
    return level.lighting && level.lighting[y] && level.lighting[y][x] || 0.2 
  end

  def self.calculate_light_level_at(level, x, y)
    # iterate through all light sources on the level
    light_level = 0.2
    level.entities.each do |entity|
      entity.wielded.each do |item|
        if item.kind == :torch
          distance = Utils::distance(entity.x, entity.y, x, y)
          if distance < 0.1
            distance = 0.1
          end
          contribution = 4.0 / (distance * distance)
          light_level += contribution
        end
      end
      entity.worn_items.each do |item|
        if item && item.kind == :ring_of_illumination
          distance = Utils::distance(entity.x, entity.y, x, y)
          if distance < 0.1
            distance = 0.1
          end
          contribution = 8.0 / (distance * distance)
          light_level += contribution
        end
      end
      # grid bugs
      if entity.species == :grid_bug
        distance = Utils::distance(entity.x, entity.y, x, y)
        if distance < 0.1
          distance = 0.1
        end
        contribution = 4.0 / (distance * distance)
        light_level += contribution
      end
    end
    level.lights.each do |light|
      distance = Utils::distance(light.x, light.y, x, y)
      if distance < 0.1
        distance = 0.1
      end
      contribution = light.intensity / (distance * distance)
      light_level += contribution
    end
    return light_level
  end

  def self.populate_lights(args)
    printf("populating lights...\n")
    dungeon = args.state.dungeon
    for level in dungeon.levels
      level.lights ||= []
      for y in 0...level.height
        for x in 0...level.width
          tile = level.tiles[y][x]
          if tile == :wall
            if args.state.rng.d20 == 1
              light = Light.new(x, y, :torch)
              level.lights << light
            end
          end
        end
      end
      # rocky levels need different lighting
      if level.vibe == :rocky
        for i in 0...(level.width * level.height / 100)
          x = args.state.rng.rand(level.width)
          y = args.state.rng.rand(level.height)
          tile = level.tiles[y][x]
          if tile == :floor
            light = Light.new(x, y, :bonfire)
            level.lights << light
          end
        end
      end 
    end
  end

  def self.calculate_lighting(level, args)
    if @@lighting_stale
      #printf("calculating lighting...\n")
      unless level.lighting
        level.lighting = Array.new(level.height) { Array.new(level.width, 0.0) }
      end
      tile_viewport = Utils.tile_viewport args
      x_start = tile_viewport[0]
      y_start = tile_viewport[1]
      x_end = tile_viewport[2]
      y_end = tile_viewport[3]
      for y in y_start..y_end
        for x in x_start..x_end
          # only if within line of sight
          if Tile.visibility_at(x, y, level.depth, args)
            level.lighting[y][x] = self.calculate_light_level_at(level, x, y)
          end
          unless level.lighting[y][x]
            level.lighting[y][x] = 0.2
          end
        end
      end
      @@lighting_stale = false
    end
  end
end

class Light
  attr_accessor :x, :y, :intensity, :kind

  def initialize(x, y, kind)
    @x = x
    @y = y
    @kind = kind
  end

  def intensity
    case @kind
    when :bonfire
      return 6.0
    when :torch
      return 4.0
    when :lamp
      return 7.5
    when :candle
      return 0.4
    end
    return 0
  end

  def self.draw_lights args
    level = Utils.level(args)
    level.lights.each do |light|
      unless Tile.is_tile_memorized?(light.x, light.y, args)
        next
      end
      case light.kind
      when :torch, :bonfire
        x = Utils.offset_x(args) + (light.x+0.25) * Utils.tile_size(args)
        y = Utils.offset_y(args) + (light.y+0.25) * Utils.tile_size(args)
        tile_size = 16
        output_tile_size = Utils.tile_size(args) / 2
        tile_selection = case light.kind
        when :torch
          [7,2]
        when :bonfire
          [14,5]
        end
        # TODO: why is this being draw on top of inspector?
        args.outputs.primitives << {
          x: x,
          y: y,
          w: output_tile_size,
          h: output_tile_size,
          path: "sprites/sm16px.png",
          tile_x: tile_selection[0] * tile_size,
          tile_y: tile_selection[1] * tile_size,
          tile_w: tile_size,
          tile_h: tile_size,
          angle: 0,
          r: 255,
          g: 140,
          b: 0,
          a: 200
        }
      end
    end
  end
end

class PortableLight < Item
  DATA = {
    torch:      { illumination: 3, directional: false, damage: 2, defense: 1, melee: 2, hit_kind: :burn, meta:{weight: 0.5, price: 5, occurance:100}},
    lamp:       { illumination: 2, directional: false, damage: 1, defense: 0, melee: 1, hit_kind: :blunt, meta:{weight: 1.5, price: 25, occurance:10}},
    candle:     { illumination: 1, directional: false, damage: 0, defense: 0, melee: 0, hit_kind: :burn, meta:{weight: 0.1, price: 1, occurance:100}},
    flashlight: { illumination: 10, directional: true, damage: 1, defense: 0, melee: 1, hit_kind: :blunt, meta:{weight: 0.5, price: 50, occurance:1}}
  }

  attr_accessor :damage, :defense, :melee, :meta, :hit_kind

  def initialize(kind, args = nil)
    # 1. Call super first to prevent Item defaults from overwriting your custom values
    super(kind, :portable_light)

    blueprint = DATA[kind] || { damage: 1, defense: 0, melee: 1, hit_kind: :blunt }
    
    # 2. init basic item and weapon attrs
    @meta = blueprint[:meta].dup
    @damage   = blueprint[:damage]
    @defense  = blueprint[:defense]
    @melee    = blueprint[:melee]
    @inaccuracy_penalty = 5
    @hit_kind = blueprint[:hit_kind] || :burn
    @weight   = @meta[:weight] || 0.5
  end

  # --- Required by Combat System ---

  def hit_kind(args = nil)
    @hit_kind || :blunt
  end

  # Fix: Change from self. (class) to instance methods and add the '?'
  def is_ranged?; false; end
  def is_throwable?; false; end
  
  # Providing the specific method your error is looking for:
  def is_ranged_weapon?; false; end
  def is_throwable_weapon?; true; end

  def self.kinds
    LIGHT_DATA.keys
  end

  # Maybe some functions to retuen light attrbutes, illmunation & direction

  def use(user, args)
    # Toggling logic similar to weapons
    if user.wielded_items.include?(self)
      user.wielded_items.delete(self)
      HUD.output_message(args, "You put away the #{self.title(args)}.")
    else
      # Add to wielded list (limit to 2 slots)
      user.wielded_items = ([self] + user.wielded_items).take(2)
      HUD.output_message(args, "You light and wield the #{self.title(args)}.")
      
      # Visual/Audio feedback
      #SoundFX.play(:light_torch, args)
    end

    # Spending time to equip
    args.state.kronos.spend_time(user, user.walking_speed * 0.5, args) if args.state.respond_to?(:kronos)
  end
end