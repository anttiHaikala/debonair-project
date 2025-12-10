# this class includes things that appear on top of floor tiles: 
# doors, beds, chairs, tables, trees, plants
# 
# furniture roration defaults:
# dors: 0 stands east-west, 90 stands north-south
# beds: 0 head on north side, 90 head on east side
# chairs: 0 faces north, 90 faces east
class Furniture

  attr_accessor :kind
  attr_accessor :x
  attr_accessor :y
  attr_accessor :depth
  attr_accessor :material
  attr_accessor :rotation # 0, 90, 180, 270 degrees
  attr_accessor :seen_by_hero
  attr_accessor :x_when_seen # we WILL need these when monsters or events start moving things around
  attr_accessor :y_when_seen 
  attr_accessor :openness # for doors: 0 closed, 1 open, float in between for possibly squeezing through
  attr_accessor :stuck
  attr_accessor :locked
  attr_accessor :key

  def initialize(kind, material, x, y, depth, rotation=0)
    @kind = kind
    @x = x
    @y = y
    @depth = depth
    @material = material
    @rotation = rotation
    @seen_by_hero = false
    @openness = 0
    @stuck = nil
    @locker = false
    @key = nil
  end

  def  self.kinds
    [
    :door,
    :bed,
    :chair,
    :table
  ]
  end

  def self.materials
    [
    :wood,
    :stone,
    :metal
  ]
  end

  def c
    [13,2]
  end

  # hsl color (cheat shett: https://www.rapidtables.com/convert/color/rgb-to-hsl.html)
  def color
    return [40, 30, 40]
  end

  def title(args)
    t = "#{@material.to_s} #{@kind.to_s}"
    if @kind == :door
      if @openness == 0
        return t + " (closed)"
      elsif @openness == 1
        return t + " (open)"
      end
    end
    return t
  end

  def self.furniture_at(x, y, level, args)
    level.furniture.each do |f|
      if f.x == x && f.y == y
        return f
      end
    end
    return nil
  end

  def self.blocks_movement?(x, y, level, args)
    furniture = Furniture.furniture_at(x, y, level, args)
    return false unless furniture
    case furniture.kind
    when :door
      if furniture.openness >= 0.5
        return false
      end
    end
    return true
  end
  def self.blocks_line_of_sight?(x, y, level, args)
    furniture = Furniture.furniture_at(x, y, level, args)
    return false unless furniture
    case furniture.kind
    when :door
      if furniture.openness >= 0.5
        return false
      end
    end
    return true
  end

  def is_toggled_by(entity, args)
    printf "Toggling furniture at %d,%d\n", @x, @y
    if @openness < 0.5
      if @locked
        HUD.output_message(args, "#{entity.name} tries to open the door, but it's locked!")
        SoundFX.play(:door_locked, args)
        return false
      end
      if @stuck
        # test of strength
        die_roll = args.state.rng.d20
        required_roll = @stuck
        if entity.age == :elder
          required_roll += 2
        elsif entity.age == :teenage
          required_roll += 1
        end
        case entity.role
        when :warrior, :samurai
          required_roll -= 3
        when :rogue
          required_roll -= 1
        when :monk, :druid
          required_roll += 1
        when :tourist, :wizard
          required_roll += 2
        end
        if entity.has_status?(:strong)
          required_roll -= 2
        end
        if die_roll < required_roll
          HUD.output_message(args, "#{entity.name} tries to open the door, but it's stuck!")
          SoundFX.play(:door_stuck, args)
          return false
        else
          HUD.output_message(args, "#{entity.name} forces the door open!")
          @stuck = false
        end
      end
      SoundFX.play(:door_open, args)
      @openness = 1.0
      args.state.kronos.spend_time(entity, entity.walking_speed * 0.25, args)
    else
      @openness = 0.0
      SoundFX.play(:door_close, args)
      # opening door is slower than closing it
      args.state.kronos.spend_time(entity, entity.walking_speed * 0.3333, args)
    end 
    GUI.mark_tiles_stale
    HUD.mark_minimap_stale
    return true
  end

  def self.remove_unsupported_doors(level, args)
    level.furniture.delete_if do |f|
      if f.kind == :door
        # check if the door is unsupported (no walls beside it at right angles)
        supported = false
        case f.rotation
        when 0, 180
          # east-west door, check north and south
          if level.tile_at(f.x, f.y - 1) == :wall || level.tile_at(f.x, f.y + 1) == :wall
            supported = true
          end
        when 90, 270
          # north-south door, check east and west
          if level.tile_at(f.x - 1, f.y) == :wall || level.tile_at(f.x + 1, f.y) == :wall
            supported = true
          end
        end
        unless supported
          #level.add_effect(:debris, f.x, f.y, args)
          true
        else
          false
        end
      else
        false
      end
    end
  end
end