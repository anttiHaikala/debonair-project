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
      entity.wielded_items.each do |item|
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
        if item.kind == :ring_of_illumination
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
  LIGHT_DATA = {
    torch:      { illumination: 3, directional: false, damage: 2, defense: 1, melee: 2, hit_kind: :burn, weight: 0.5, price: 5 },
    lamp:       { illumination: 3, directional: false, damage: 1, defense: 0, melee: 1, hit_kind: :blunt, weight: 1.5, price: 25 },
    candle:     { illumination: 3, directional: false, damage: 0, defense: 0, melee: 0, hit_kind: :burn, weight: 0.1, price: 1 },
    flashlight: { illumination: 3, directional: false, damage: 1, defense: 0, melee: 1, hit_kind: :blunt, weight: 0.8, price: 50 }
  }

  attr_accessor :damage, :defense, :melee, :meta
  attr_writer :hit_kind

  def initialize(kind, args = nil)
    # 1. Call super first to prevent Item defaults from overwriting your custom values
    super(kind, :portable_light)

    blueprint = LIGHT_DATA[kind] || { damage: 1, defense: 0, melee: 1, hit_kind: :blunt }
    
    # 2. Standardize names to @defense (with an 's') to match Weapon/Armor logic
    @damage   = blueprint[:damage]
    @defense  = blueprint[:defense]
    @melee    = blueprint[:melee]
    @hit_kind = blueprint[:hit_kind]
    @weight   = blueprint[:weight] || 0.5
    
    # 3. Ensure @meta exists so it doesn't crash UI lookups
    @meta = { price: blueprint[:price] || 5, material: :mixed }
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
  def is_throwable_weapon?; false; end

  def self.kinds
    LIGHT_DATA.keys
  end

  def use(user, args)
    # Logic for toggling light source could go here
    HUD.output_message(args, "You light the #{self.kind}.")
  end
end