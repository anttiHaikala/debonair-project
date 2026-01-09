# even though final levels consist of tiles, room objects are used during level generation
# and can remain available during the game in case they are needed

class Room

  attr_accessor :x, :y, :w, :h, :traits, :name

  def initialize(x, y, w, h)
    @x = x
    @y = y
    @w = w
    @h = h
    @traits = [] 
    @name = random_name
  end

  def random_name
    prefixes = ["Shadow", "Whispering", "Silent", "Dark", "Hidden", "Misty", "Ancient", "Forgotten", "Creeping", "Twisted", 'Glowing', "Minstrel's", 'Dwarven', 'Orcish', 'Elven', 'Goblin', 'Haunted', 'Crystal', 'Golden', 'Silver', 'Bronze', 'Iron', 'Copper', 'Rainbow', 'Silent', 'Noisy']
    suffixes = ["Chamber", 'Nest', "Hall", "Room", "Sanctum", "Lair", "Den", "Vault", "Crypt", "Catacomb", 'Boudoir', 'Parlor', 'Salon', 'Study', 'Library', 'Armory', 'Barracks', 'Dormitory', 'Gallery', 'Observatory', 'Shrine', 'Temple', 'Workshop', 'Laboratory', 'Forge']
    prefix = prefixes.sample
    suffix = suffixes.sample
    return "#{prefix} #{suffix}"
  end

  def random_square_inside(args)
    x_adjustment = args.state.rng.nxt_int(1, @w - 2)
    y_adjustment = args.state.rng.nxt_int(1, @h - 2)
    return [@x + x_adjustment, @y + y_adjustment]
  end

  def empty_square(args)
    max_attempts = 100
    attempts = 0
    while attempts < max_attempts
      candidate_x, candidate_y = random_square_inside(args)
      if args.state.map.is_empty_at?(candidate_x, candidate_y)
        return [candidate_x, candidate_y]
      end
      attempts += 1
    end
    return nil
  end

  def width
    return @w
  end

  def height
    return @h
  end

  def center
    return [center_x, center_y]
  end

  def center_x
    return (x + (w / 2)).to_i
  end
  
  def center_y
    return (y + (h / 2)).to_i
  end

  def intersects?(other)
    return !(@x + @w < other.x || other.x + other.w < @x ||
             @y + @h < other.y || other.y + other.h < @y)
  end

  # used for debugging purposes only
  def color
    hue_seed = @x * 37 + @y * 57 + @w * 23 + @h * 43 # random for each room
    hue = hue_seed % 360
    saturation = 100
    lightness = 80
    rgb = Color.hsl_to_rgb(hue, saturation, lightness)
    return rgb
  end
end

class Corridor
  attr_accessor :x1, :y1, :x2, :y2, :steps, :name
  def initialize(x1, y1, x2, y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
    @name = random_name
    @steps = []
  end

  def random_name
    prefixes = ["Shadow", "Whispering", "Silent", "Dark", "Hidden", "Misty", "Ancient", "Forgotten", "Creeping", "Twisted", 'Glowing', "Minstrel's", 'Dwarven', 'Orcish', 'Elven', 'Goblin', 'Haunted', 'Crystal', 'Golden', 'Silver', 'Bronze', 'Iron', 'Copper', 'Rainbow', 'Silent', 'Noisy']
    suffixes = ["Passage", "Way", "Path", "Tunnel", "Route", "Hall", "Gallery", "Avenue", "Lane", "Drive", 'Hallway', 'Walk', 'Run', 'Ring', 'Trail', 'Haunt', 'Block', 'Boulevard', 'Laneway', 'Loop', 'Promenade', 'Track', 'Sneak', 'Subway', 'Sprint', 'Alley', 'Marathon', 'Broadway', 'Shortcut', 'Byway']
    prefix = prefixes.sample
    suffix = suffixes.sample
    return "#{prefix} #{suffix}"
  end

  # used for debugging purposes only
  def color
    hue_seed = @x1 * 37 + @y1 * 57 + @x2 * 23 + @y2 * 43 # random for each room
    hue = hue_seed % 360
    saturation = 100
    lightness = 80
    rgb = Color.hsl_to_rgb(hue, saturation, lightness)
    return rgb
  end

end