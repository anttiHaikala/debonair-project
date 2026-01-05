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
  attr_accessor :breakable # nil = unbreakable, else integer hit points that also determine how hard it is to damage

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
    @breakable = 10
  end

  def self.kinds
    [
    :door,
    :bed,
    :chair,
    :table,
    :secret_door,
    :chest,
    :boulder,
    :pit
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

  def hidden?
    if @kind == :secret_door && @seen_by_hero == false
      return true
    end
    return false
  end

  def title(args)
    t = "#{@material.to_s} #{@kind.to_s}".gsub('_',' ') 
    if @kind == :door
      if @openness == 0
        return t + " (closed)"
      elsif @openness == 1
        return t + " (open)"
      end
    end
    if kind == :boulder || kind == :pit
      t = t.gsub('stone', '').gsub('rock', '')
    end
    return t.gsub('  ',' ').strip
  end

  def self.furniture_at(x, y, level, args)
    level.furniture.each do |f|
      if f.x == x && f.y == y
        return f
      end
    end
    return nil
  end

  def blocks_movement? args
    case self.kind
    when :pit
      return false
    when :door, :secret_door, :boulder
      if self.openness > 0.0
        return false
      end
    end
    return true
  end

  def self.blocks_movement?(x, y, level, args)
    furniture = Furniture.furniture_at(x, y, level, args)
    if furniture && furniture.blocks_movement?(args) 
      return true
    end
  end

  def blocks_line_of_sight?(args)
    self.blocks_movement?(args)
  end

  def self.blocks_line_of_sight?(x, y, level, args)
    furniture = Furniture.furniture_at(x, y, level, args)
    if furniture && furniture.blocks_line_of_sight?(args) 
      return true
    end
    return false
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
        when 90, 270
          # east-west door, check north and south
          if level.tile_at(f.x, f.y - 1) == :wall || level.tile_at(f.x, f.y + 1) == :wall
            supported = true
          end
        when 0, 180
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

  def self.add_boulders_and_pits(level, args)
    num_boulders = args.state.rng.d6
    num_pits = args.state.rng.d6

    if args.state.rng.d6 > 2
      num_boulders = 0
    end
    if args.state.rng.d6 > 2
      num_pits = 0
    end

    num_boulders.times do
      safety = 0
      placed = false
      while !placed do
        safety += 1
        if safety > 100
          printf "Could not place boulder after 100 tries, giving up.\n"
          break
        end
        x = Numeric.rand(1...(level.width - 1)).to_i
        y = Numeric.rand(1...(level.height - 1)).to_i
        if level.tile_at(x, y) == :floor && !Furniture.furniture_at(x, y, level, args)
          boulder = Furniture.new(:boulder, :rock, x, y, level.depth, 0)
          level.furniture << boulder
          placed = true
        end
      end
    end

    num_pits.times do
      safety = 0
      placed = false
      while !placed do
        safety += 1
        if safety > 100
          printf "Could not place pit after 100 tries, giving up.\n"
          break
        end
        x = Numeric.rand(1...(level.width - 1)).to_i
        y = Numeric.rand(1...(level.height - 1)).to_i
        if level.tile_at(x, y) == :floor && !Furniture.furniture_at(x, y, level, args)
          pit = Furniture.new(:pit, :rock, x, y, level.depth, 0)
          level.furniture << pit
          placed = true
        end
      end
    end
  end
end